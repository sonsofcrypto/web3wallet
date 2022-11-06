package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

sealed class NFTsDashboardWireframeDestination {
    data class ViewCollectionNFTs(val collectionId: String): NFTsDashboardWireframeDestination()
    data class ViewNFT(val nftItem: NFTItem): NFTsDashboardWireframeDestination()
    data class SendError(val msg: String): NFTsDashboardWireframeDestination()
}

interface NFTsDashboardWireframe {
    fun present()
    fun navigate(destination: NFTsDashboardWireframeDestination)
}

