package com.sonsofcrypto.web3walletcore.modules.nftsCollection

data class NFTsCollectionWireframeContext(val collectionId: String)

sealed class NFTsCollectionWireframeDestination {
    data class NFTDetail(
        val collectionId: String,
        val nftId: String
    ): NFTsCollectionWireframeDestination()
    object Dismiss: NFTsCollectionWireframeDestination()
}

interface NFTsCollectionWireframe {
    fun present()
    fun navigate(destination: NFTsCollectionWireframeDestination)
}
