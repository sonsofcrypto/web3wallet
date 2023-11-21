package com.sonsofcrypto.web3walletcore.common.viewModels

class ButtonViewModel(
    val title: String,
    val kind: Kind = Kind.PRIMARY,
    val iconName: String? = null,
) {
    enum class Kind {
        PRIMARY, SECONDARY, DESTRUCTIVE
    }
}