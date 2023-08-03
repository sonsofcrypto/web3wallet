package com.sonsofcrypto.web3walletcore.modules.nftsCollection

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframeDestination.Back
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframeDestination.NFTDetail
import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

sealed class NFTsCollectionPresenterEvent {
    object Back: NFTsCollectionPresenterEvent()
    data class NFTDetail(val idx: Int): NFTsCollectionPresenterEvent()
}

interface NFTsCollectionPresenter {
    fun present()
    fun handle(event: NFTsCollectionPresenterEvent)
}

class DefaultNFTsCollectionPresenter(
    private val view: WeakRef<NFTsCollectionView>,
    private val wireframe: NFTsCollectionWireframe,
    private val interactor: NFTsCollectionInteractor,
    private val context: NFTsCollectionWireframeContext,
): NFTsCollectionPresenter {

    private var collection: NFTCollection = interactor.fetchCollection(context.collectionId)
    private var nfts: List<NFTItem> = interactor.fetchNFTs(context.collectionId)

    override fun present() { updateView() }

    override fun handle(event: NFTsCollectionPresenterEvent) {
        when (event) {
            is NFTsCollectionPresenterEvent.NFTDetail -> {
                wireframe.navigate(NFTDetail(nfts[event.idx].identifier))
            }
            is NFTsCollectionPresenterEvent.Back -> wireframe.navigate(Back)
        }
    }

    private fun updateView() {
        view.get()?.update(NFTsCollectionViewModel(collection, nfts))
    }
}