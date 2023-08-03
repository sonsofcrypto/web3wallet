package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

data class NFTDetailWireframeContext(
    val nftId: String,
    val collectionId: String,
)

sealed class NFTDetailWireframeDestination {
    data class Send(val nft: NFTItem): NFTDetailWireframeDestination()
    object Back: NFTDetailWireframeDestination()
}

interface NFTDetailWireframe {
    fun present()
    fun navigate(destination: NFTDetailWireframeDestination)
}