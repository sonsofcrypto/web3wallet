package com.sonsofcrypto.web3walletcore.modules.nftsCollection

data class NFTsCollectionWireframeContext(
    val collectionId: String,
)

sealed class NFTsCollectionWireframeDestination {
    data class NFTDetail(val identifier: String): NFTsCollectionWireframeDestination()
    object Back: NFTsCollectionWireframeDestination()
}

interface NFTsCollectionWireframe {
    fun present()
    fun navigate(destination: NFTsCollectionWireframeDestination)
}
