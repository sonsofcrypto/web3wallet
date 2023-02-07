package com.sonsofcrypto.web3walletcore.modules.degen

data class DegenViewModel(
    val sections: List<Section>
) {

    // NOTE: This should just be Section(title, enable, items. No need for additional structs)
    // NOTE: On the second look this is flat out retarded. Did you change this because of compose
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
