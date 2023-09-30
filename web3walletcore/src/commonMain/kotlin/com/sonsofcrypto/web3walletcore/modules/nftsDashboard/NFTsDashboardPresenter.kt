package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3lib.utils.withUICxt
import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardPresenterEvent.ErrAction
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardPresenterEvent.Refresh
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Collection
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Error
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Loaded
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.Loading
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardViewModel.NFT
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination.SendError
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination.ViewCollectionNFTs
import com.sonsofcrypto.web3walletcore.modules.nftsDashboard.NFTsDashboardWireframeDestination.ViewNFT
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class NFTsDashboardPresenterEvent {
    data class ViewCollectionNFTs(val idx: Int): NFTsDashboardPresenterEvent()
    data class ViewNFT(val idx: Int): NFTsDashboardPresenterEvent()
    data class ErrAction(val idx: Int): NFTsDashboardPresenterEvent()
    object Refresh: NFTsDashboardPresenterEvent()
}

interface NFTsDashboardPresenter {
    fun present()
    fun handle(event: NFTsDashboardPresenterEvent)
}

class DefaultNFTsDashboardPresenter(
    private val view: WeakRef<NFTsDashboardView>,
    private val wireframe: NFTsDashboardWireframe,
    private val interactor: NFTsDashboardInteractor,
): NFTsDashboardPresenter, NFTsDashboardInteractorLister  {
    private val bgScope = CoroutineScope(bgDispatcher)
    private val uiScope = CoroutineScope(uiDispatcher)
    private var isLoading: Boolean =  false
    private var err: Throwable? = null
    /** `errCache` needed due to potential race conditions, between user
     * handling error and new async events causing viewModel update */
    private var errCache: Throwable? = null

    init {
        interactor.add(this)
    }

    override fun present() {
        isLoading = true
        updateView()
        bgScope.launch {
            try {
                interactor.fetchYourNFTs()
                withUICxt { updateView() }
            } catch (e: Throwable) {
                err = e
                withUICxt { updateView() }
            }
        }
    }

    override fun handle(event: NFTsDashboardPresenterEvent) {
        when (event) {
            is NFTsDashboardPresenterEvent.ViewNFT -> {
                wireframe.navigate(ViewNFT(interactor.nfts()[event.idx]))
            }
            is NFTsDashboardPresenterEvent.ViewCollectionNFTs -> {
                val collId = interactor.collections()[event.idx].identifier
                wireframe.navigate(ViewCollectionNFTs(collId))
            }
            is Refresh -> present()
            is ErrAction -> {
                if (err != null && event.idx == 1) {
                    val e = err ?: errCache
                    val errMgs = Localized("nfts.dashboard.error.email.body", e)
                    wireframe.navigate(SendError(errMgs))
                }
                err = null
            }
        }
    }

    override fun networkChanged() {
        uiScope.launch { view.get()?.popToRootAndRefresh() }
    }

    override fun nftsChanged() { uiScope.launch { updateView() } }

    private fun updateView() {
        if (isLoading) {
            view.get()?.update(Loading)
            isLoading = false
            return
        }
        if (err != null) {
            println("[NFTsDashboardPresenter] error: $err")
            val errorViewModel = ErrorViewModel(
                Localized("error"),
                Localized("nfts.dashboard.error.message"),
                listOf(Localized("cancel"), Localized("sendLogs"))
            )
            view.get()?.update(Error(errorViewModel))
            errCache = err
            err = null
            return
        }
        val nftsViewModel = interactor.nfts().map {
            NFT(
                it.identifier,
                it.gatewayImageUrl,
                it.gatewayPreviewImageUrl,
                it.mimeType,
                it.fallbackText
            )
        }
        val collectionsViewModel = interactor.collections().map {
            Collection(it.identifier, it.coverImage, it.title, it.author)
        }
        view.get()?.update(Loaded(nftsViewModel, collectionsViewModel))
    }
}
