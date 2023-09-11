package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeDestination.Send

sealed class NFTDetailPresenterEvent {
    object Send: NFTDetailPresenterEvent()
    object Dismiss: NFTDetailPresenterEvent()
}

interface NFTDetailPresenter {
    fun present()
    fun handle(event: NFTDetailPresenterEvent)
}

class DefaultNFTDetailPresenter(
    private val view: WeakRef<NFTDetailView>,
    private val wireframe: NFTDetailWireframe,
    private val interactor: NFTDetailInteractor,
    private val context: NFTDetailWireframeContext,
): NFTDetailPresenter {
    private var nft = interactor.fetchNFT(context.collectionId, context.nftId)
    private var collection = interactor.fetchCollection(context.collectionId)

    override fun present() { updateView() }

    override fun handle(event: NFTDetailPresenterEvent) {
        when(event) {
            is NFTDetailPresenterEvent.Send -> wireframe.navigate(Send(nft))
            is NFTDetailPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    private fun updateView() {
        view.get()?.update(NFTDetailViewModel(nft,  collection))
    }
}
