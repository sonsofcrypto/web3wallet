package com.sonsofcrypto.web3walletcore.modules.accountImport

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.Type.PRVKEY

data class AccountImportWireframeContext(
    val signerType: SignerStoreItem.Type = PRVKEY,
    val handler: ((SignerStoreItem) -> Unit),
)

sealed class AccountImportWireframeDestination {
    object Dismiss: AccountImportWireframeDestination()
}

interface AccountImportWireframe {
    fun present()
    fun navigate(destination: AccountImportWireframeDestination)
}
