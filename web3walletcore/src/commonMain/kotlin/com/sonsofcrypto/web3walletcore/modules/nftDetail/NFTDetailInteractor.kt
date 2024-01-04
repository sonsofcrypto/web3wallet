package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

interface NFTDetailInteractor {
    fun fetchNFT(collectionId: String, tokenId: String): NFTItem
    fun fetchCollection(id: String): NFTCollection
    fun isVoidSigner(): Boolean
}

class DefaultNFTDetailInteractor(
    private val nftService: NFTsService,
    private val walletService: WalletService
): NFTDetailInteractor {

    override fun fetchNFT(collectionId: String, tokenId: String): NFTItem =
        nftService.nft(collectionId, tokenId)

    override fun fetchCollection(id: String): NFTCollection =
        nftService.collection(id)

    override fun isVoidSigner(): Boolean =
        walletService.isSelectedVoidSigner()
}
