package com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext

data class PrvKeyUpdateWireframeContext(
    val signerStoreItem: SignerStoreItem,
    val updateHandler: ((SignerStoreItem) -> Unit),
    val deleteHandler: (() -> Unit),
)

sealed class PrvKeyUpdateWireframeDestination {
    data class Authenticate(val context: AuthenticateWireframeContext): PrvKeyUpdateWireframeDestination()
    data class Alert(val context: AlertWireframeContext): PrvKeyUpdateWireframeDestination()
    object Dismiss: PrvKeyUpdateWireframeDestination()
}

interface PrvKeyUpdateWireframe {
    fun present()
    fun navigate(destination: PrvKeyUpdateWireframeDestination)
}