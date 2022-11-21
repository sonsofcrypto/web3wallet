package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem

data class MnemonicNewWireframeContext(
    val handler: ((KeyStoreItem) -> Unit),
)

sealed class MnemonicNewWireframeDestination {
    object LearnMoreSalt: MnemonicNewWireframeDestination()
    object Dismiss: MnemonicNewWireframeDestination()
}

interface MnemonicNewWireframe {
    fun present()
    fun navigate(destination: MnemonicNewWireframeDestination)
}
