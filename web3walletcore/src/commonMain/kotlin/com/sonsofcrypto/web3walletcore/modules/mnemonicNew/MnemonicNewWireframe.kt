package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem

data class MnemonicNewWireframeContext(
    val handler: ((SignerStoreItem) -> Unit),
)

sealed class MnemonicNewWireframeDestination {
    object LearnMoreSalt: MnemonicNewWireframeDestination()
    object Dismiss: MnemonicNewWireframeDestination()
}

interface MnemonicNewWireframe {
    fun present()
    fun navigate(destination: MnemonicNewWireframeDestination)
}
