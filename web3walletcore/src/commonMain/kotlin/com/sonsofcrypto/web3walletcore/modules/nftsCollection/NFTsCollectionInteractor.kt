package com.sonsofcrypto.web3walletcore.modules.nftsCollection

import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

interface NFTsCollectionInteractor {
    fun collection(collectionId: String): NFTCollection
    fun nfts(collectionId: String): List<NFTItem>
    fun clearCache()
}

class DefaultNFTsCollectionInteractor(
    private val nftsService: NFTsService,
): NFTsCollectionInteractor {
    private var collections: MutableMap<String, NFTCollection> = mutableMapOf()
    private var nfts: MutableMap<String, List<NFTItem>> = mutableMapOf()

    override fun clearCache() {
        collections = mutableMapOf()
        nfts = mutableMapOf()
    }

    override fun collection(collectionId: String): NFTCollection {
        val collection = collections[collectionId]
            ?: nftsService.collection(collectionId)
        collections[collectionId] = collection
        return collection

    }


    override fun nfts(collectionId: String): List<NFTItem> {
        val collectionNfts = nfts[collectionId]
            ?: nftsService.nfts(collectionId)
        nfts[collectionId] = collectionNfts
        return collectionNfts
    }
}
