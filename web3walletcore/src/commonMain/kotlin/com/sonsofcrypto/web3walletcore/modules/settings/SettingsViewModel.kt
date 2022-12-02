package com.sonsofcrypto.web3walletcore.modules.settings

data class SettingsViewModel(
    val title: String,
    val sections: List<Section>,
) {
    data class Section(
        val header: String?,
        val items: List<Item>,
        val footer: Footer?,
    ) {
        data class Item(
            val title: String,
            val isAction: Boolean,
            val isSelected: Boolean?
        )
        data class Footer(
            val title: String,
            val alignment: Alignment
        ) {
            enum class Alignment { LEFT, CENTER }
        }
    }
}