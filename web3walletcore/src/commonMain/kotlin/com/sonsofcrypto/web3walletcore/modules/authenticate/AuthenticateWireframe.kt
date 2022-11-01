package com.sonsofcrypto.web3walletcore.modules.authenticate

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem

data class AuthenticateData(
    val password: String,
    val salt: String,
)

data class AuthenticateWireframeContext(
    val title: String,
    val keyStoreItem: KeyStoreItem?,
    val handler: (AuthenticateData?, Error?) -> Unit,
)

interface AuthenticateWireframe {
    /** Present module */
    fun present()
    /** Navigate to a new destination module */
    fun navigate(destination: AuthenticateWireframeDestination)
}

sealed class AuthenticateWireframeDestination {
    /** Call to dismiss the module. */
    object Dismiss: AuthenticateWireframeDestination()
}