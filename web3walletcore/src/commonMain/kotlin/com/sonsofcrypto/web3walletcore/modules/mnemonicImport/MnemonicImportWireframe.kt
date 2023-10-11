package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem

data class MnemonicImportWireframeContext(
    val handler: ((SignerStoreItem) -> Unit),
)

sealed class MnemonicImportWireframeDestination {
    object LearnMoreSalt: MnemonicImportWireframeDestination()
    object Dismiss: MnemonicImportWireframeDestination()
}

interface MnemonicImportWireframe {
    fun present()
    fun navigate(destination: MnemonicImportWireframeDestination)
}
