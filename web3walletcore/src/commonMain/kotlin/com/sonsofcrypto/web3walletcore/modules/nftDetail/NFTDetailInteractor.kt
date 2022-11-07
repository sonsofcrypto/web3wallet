package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

interface NFTDetailInteractor {
    fun fetchNFT(identifier: String): NFTItem
    fun fetchCollection(identifier: String): NFTCollection
}

class DefaultNFTDetailInteractor(
    private val nftService: NFTsService,
): NFTDetailInteractor {

    override fun fetchNFT(identifier: String): NFTItem = nftService.nft(identifier)

    override fun fetchCollection(identifier: String): NFTCollection =
        nftService.collection(identifier)
}
