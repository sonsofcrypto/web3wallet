package com.sonsofcrypto.web3walletcore.modules.networkSettings

data class NetworkSettingsViewModel(
    val items: List<Item>,
    val selectedIdx: Int
) {
    data class Item(val title: String)
}