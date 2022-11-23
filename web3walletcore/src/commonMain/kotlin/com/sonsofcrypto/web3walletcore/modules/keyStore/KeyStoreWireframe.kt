package com.sonsofcrypto.web3walletcore.modules.keyStore

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem

sealed class KeyStoreWireframeDestination {

    object HideNetworksAndDashboard: KeyStoreWireframeDestination()
    object Networks: KeyStoreWireframeDestination()
    object Dashboard: KeyStoreWireframeDestination()
    object DashboardOnboarding: KeyStoreWireframeDestination()
    data class EditKeyStoreItem(
        val item: KeyStoreItem, val handler: (KeyStoreItem) -> Unit, val onDeleted: () -> Unit
    ): KeyStoreWireframeDestination()
    data class NewMnemonic(val handler: (KeyStoreItem) -> Unit): KeyStoreWireframeDestination()
    data class ImportMnemonic(val handler: (KeyStoreItem) -> Unit): KeyStoreWireframeDestination()
    object ConnectHardwareWallet: KeyStoreWireframeDestination()
    object ImportPrivateKey: KeyStoreWireframeDestination()
    object CreateMultisig: KeyStoreWireframeDestination()
}

interface KeyStoreWireframe {
    fun present()
    fun navigate(destination: KeyStoreWireframeDestination)
}
