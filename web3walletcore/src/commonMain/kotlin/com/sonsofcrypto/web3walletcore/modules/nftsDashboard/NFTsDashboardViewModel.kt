package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel

sealed class NFTsDashboardViewModel {
    object Loading: NFTsDashboardViewModel()
    data class Error(val error: ErrorViewModel): NFTsDashboardViewModel()
    data class Loaded(
        val nfts: List<NFT>,
        val collections: List<Collection>,
        val regularCarousel: Boolean
    ): NFTsDashboardViewModel()

    data class NFT(
        val identifier: String,
        val image: String,
        val previewImage: String?,
        val mimeType: String?,
        val fallbackText: String?
    )

    data class Collection(
        val identifier: String,
        val coverImage: String?,
        val title: String,
        val author: String?,
    )
}

fun NFTsDashboardViewModel.nfts(): List<NFTsDashboardViewModel.NFT> {
    return if (this is NFTsDashboardViewModel.Loaded) return this.nfts
    else emptyList()
}

fun NFTsDashboardViewModel.collections(): List<NFTsDashboardViewModel.Collection> {
    return if (this is NFTsDashboardViewModel.Loaded) return this.collections
    else emptyList()
}
