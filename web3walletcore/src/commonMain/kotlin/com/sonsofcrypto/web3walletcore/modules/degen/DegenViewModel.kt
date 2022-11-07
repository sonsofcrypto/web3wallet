package com.sonsofcrypto.web3walletcore.modules.degen

data class DegenViewModel(
    val sections: List<Section>
) {

    sealed class Section {
        data class Header(val title: String, val isEnabled: Boolean): Section()
        data class Group(val items: List<Item>): Section()
    }

    data class Item(
        val iconName: String,
        val title: String,
        val subtitle: String,
        val isEnabled: Boolean,
    )
}
