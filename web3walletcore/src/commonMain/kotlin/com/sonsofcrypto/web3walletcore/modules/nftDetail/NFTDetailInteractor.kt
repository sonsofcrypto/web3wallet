package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

interface NFTDetailInteractor {
    fun fetchNFT(collectionId: String, tokenId: String): NFTItem
    fun fetchCollection(id: String): NFTCollection
}

class DefaultNFTDetailInteractor(
    private val nftService: NFTsService,
): NFTDetailInteractor {

    override fun fetchNFT(collectionId: String, tokenId: String): NFTItem =
        nftService.nft(collectionId, tokenId)

    override fun fetchCollection(id: String): NFTCollection =
        nftService.collection(id)
}
