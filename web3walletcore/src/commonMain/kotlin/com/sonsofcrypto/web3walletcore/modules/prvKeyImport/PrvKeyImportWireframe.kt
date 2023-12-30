package com.sonsofcrypto.web3walletcore.modules.prvKeyImport

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem

data class PrvKeyImportWireframeContext(
    val handler: ((SignerStoreItem) -> Unit),
)

sealed class PrvKeyImportWireframeDestination {
    object Dismiss: PrvKeyImportWireframeDestination()
}

interface PrvKeyImportWireframe {
    fun present()
    fun navigate(destination: PrvKeyImportWireframeDestination)
}
