package com.sonsofcrypto.web3walletcore.common.viewModels

sealed class CollectionViewModel {

    data class Item(
        val cellViewModel: CellViewModel,
    ): CollectionViewModel()

    data class Section(
        val header: String?,
        val items: List<Item>,
        val footer: String?
    ): CollectionViewModel()

    data class Screen(
        val id: String,
        val sections: List<Section>
    ): CollectionViewModel()

}