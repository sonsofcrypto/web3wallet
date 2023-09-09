package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3lib.utils.withUICxt
import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Collection
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Error
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Loaded
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Loading
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.NFT
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination.SendError
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination.ViewCollectionNFTs
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination.ViewNFT
import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class NFTsDashboardPresenterEvent {
    data class ViewCollectionNFTs(val idx: Int): NFTsDashboardPresenterEvent()
    data class ViewNFT(val idx: Int): NFTsDashboardPresenterEvent()
    object CancelError: NFTsDashboardPresenterEvent()
    object SendError: NFTsDashboardPresenterEvent()
}

interface NFTsDashboardPresenter {
    fun present(isPullDownToRefresh: Boolean)
    fun handle(event: NFTsDashboardPresenterEvent)
    fun releaseResources()
}

class DefaultNFTsDashboardPresenter(
    private val view: WeakRef<NFTsDashboardView>,
    private val wireframe: NFTsDashboardWireframe,
    private val interactor: NFTsDashboardInteractor,
): NFTsDashboardPresenter, NFTsDashboardInteractorLister  {
    private val bgScope = CoroutineScope(bgDispatcher)
    private val uiScope = CoroutineScope(uiDispatcher)
    private var nfts: List<NFTItem> = emptyList()
    private var collections: List<NFTCollection> = emptyList()
    private var err: Throwable? = null

    init {
        interactor.add(this)
    }

    override fun present(isPullDownToRefresh: Boolean) {
        if (!isPullDownToRefresh) { view.get()?.update(Loading) }
        bgScope.launch {
            try {
                nfts = interactor.fetchYourNFTs(isPullDownToRefresh)
                collections = interactor.yourCollections()
                withUICxt { updateView() }
            } catch (e: Throwable) {
                err = e
                withUICxt {
                    val errorViewModel = ErrorViewModel(
                        Localized("error"),
                        Localized("nfts.dashboard.error.message"),
                        listOf(Localized("cancel"), Localized("sendLogs"))
                    )
                    view.get()?.update(Error(errorViewModel))
                }
            }
        }
    }

    override fun handle(event: NFTsDashboardPresenterEvent) {
        when (event) {
            is NFTsDashboardPresenterEvent.ViewNFT -> {
                wireframe.navigate(ViewNFT(nfts[event.idx]))
            }
            is NFTsDashboardPresenterEvent.ViewCollectionNFTs -> {
                wireframe.navigate(ViewCollectionNFTs(collections[event.idx].identifier))
            }
            is NFTsDashboardPresenterEvent.CancelError -> err = null
            is NFTsDashboardPresenterEvent.SendError -> {
                if (err == null) return
                wireframe.navigate(SendError(Localized("nfts.dashboard.error.email.body", err!!)))
                err = null
            }
        }
    }

    override fun releaseResources() { interactor.remove(this) }

    override fun networkChanged() { uiScope.launch { view.get()?.popToRootAndRefresh() } }

    override fun nftsChanged() { uiScope.launch { present(isPullDownToRefresh = false) } }

    private fun updateView() {
        val nftsViewModel = nfts.map {
            NFT(it.identifier, it.gatewayImageUrl, it.gatewayPreviewImageUrl)
        }
        val collectionsViewModel = interactor.yourCollections().map {
            Collection(it.identifier, it.coverImage, it.title, it.author)
        }
        view.get()?.update(Loaded(nftsViewModel, collectionsViewModel))
    }
}
