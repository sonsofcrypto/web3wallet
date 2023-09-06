package com.sonsofcrypto.web3walletcore.modules.nftsCollection

import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

interface NFTsCollectionInteractor {
    fun fetchCollection(collectionId: String): NFTCollection
    fun fetchNFTs(collectionId: String): List<NFTItem>
}

class DefaultNFTsCollectionInteractor(
    private val nftsService: NFTsService,
): NFTsCollectionInteractor {

    override fun fetchCollection(collectionId: String): NFTCollection =
        nftsService.collection(collectionId)

    override fun fetchNFTs(collectionId: String): List<NFTItem> =
        nftsService.nfts(collectionId)
}
