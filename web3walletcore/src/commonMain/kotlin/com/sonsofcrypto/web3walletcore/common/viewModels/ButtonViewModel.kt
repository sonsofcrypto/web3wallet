package com.sonsofcrypto.web3walletcore.common.viewModels

class ButtonViewModel(
    val title: String,
    val style: Style = Style.PRIMARY,
    val iconName: String? = null,
) {
    enum class Style {
        PRIMARY, SECONDARY, DESTRUCTIVE
    }
}