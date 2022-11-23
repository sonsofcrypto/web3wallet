package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem

data class MnemonicImportWireframeContext(
    val handler: ((KeyStoreItem) -> Unit),
)

sealed class MnemonicImportWireframeDestination {
    object LearnMoreSalt: MnemonicImportWireframeDestination()
    object Dismiss: MnemonicImportWireframeDestination()
}

interface MnemonicImportWireframe {
    fun present()
    fun navigate(destination: MnemonicImportWireframeDestination)
}
