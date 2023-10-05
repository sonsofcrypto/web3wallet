package com.sonsofcrypto.web3walletcore.modules.nftsCollection

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.withUICxt
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionPresenterEvent.Select
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframeDestination.NFTDetail
import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class NFTsCollectionPresenterEvent {
    data class Select(val idx: Int): NFTsCollectionPresenterEvent()
    object Dismiss: NFTsCollectionPresenterEvent()
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
    private var collection: NFTCollection? = null
    private var nfts: List<NFTItem> = emptyList()

    override fun present() {
        view.get()?.update(NFTsCollectionViewModel.Loading)
        CoroutineScope(bgDispatcher).launch {
            interactor.clearCache()
            val fetchedCollection = interactor.collection(context.collectionId)
            val fetchedNfts = interactor.nfts(context.collectionId)
            withUICxt {
                collection = fetchedCollection
                nfts = fetchedNfts
                updateView()
            }
        }
    }

    override fun handle(event: NFTsCollectionPresenterEvent) = when (event) {
        is Select -> {
            wireframe.navigate(
                NFTDetail(context.collectionId, nfts[event.idx].identifier)
            )
        }
        is NFTsCollectionPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
    }

    private fun updateView() {
        view.get()?.update(
            NFTsCollectionViewModel.Loaded(
                NFTsCollectionViewModel.Collection(
                    collection?.identifier ?: context.collectionId,
                    collection?.coverImage,
                    collection?.title ?: context.collectionId,
                    collection?.author
                ),
                nfts.map {
                    NFTsCollectionViewModel.NFT(
                        it.identifier,
                        it.gatewayImageUrl,
                        it.gatewayPreviewImageUrl,
                        it.mimeType,
                        it.fallbackText
                    )
                }
            )
        )
    }
}