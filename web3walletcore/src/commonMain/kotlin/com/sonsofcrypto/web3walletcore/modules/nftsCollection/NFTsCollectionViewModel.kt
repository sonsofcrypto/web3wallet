package com.sonsofcrypto.web3walletcore.modules.nftsCollection


sealed class NFTsCollectionViewModel {
    object Loading : NFTsCollectionViewModel()
    data class Loaded(
        val collection: Collection,
        val nfts: List<NFT>,
    ) : NFTsCollectionViewModel()

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

fun NFTsCollectionViewModel.nfts(): List<NFTsCollectionViewModel.NFT> {
    return if (this is NFTsCollectionViewModel.Loaded) return this.nfts
    else emptyList()
}

fun NFTsCollectionViewModel.collection(): NFTsCollectionViewModel.Collection? {
    return if (this is NFTsCollectionViewModel.Loaded) return this.collection
    else null
}
