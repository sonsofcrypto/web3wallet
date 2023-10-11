package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem

sealed class SignersWireframeDestination {

    object SignersFullscreen: SignersWireframeDestination()
    object Networks: SignersWireframeDestination()
    object Dashboard: SignersWireframeDestination()
    object DashboardOnboarding: SignersWireframeDestination()
    data class EditSignersItem(
        val item: SignerStoreItem,
        val handler: (SignerStoreItem) -> Unit,
        val deleteHandler: () -> Unit
    ): SignersWireframeDestination()
    data class NewMnemonic(
        val handler: (SignerStoreItem) -> Unit
    ): SignersWireframeDestination()
    data class ImportMnemonic(
        val handler: (SignerStoreItem) -> Unit
    ): SignersWireframeDestination()
    object ImportPrivateKey: SignersWireframeDestination()
    object ImportAddress: SignersWireframeDestination()
    object ConnectHardwareWallet: SignersWireframeDestination()
    object CreateMultisig: SignersWireframeDestination()
}

interface SignersWireframe {
    fun present()
    fun navigate(destination: SignersWireframeDestination)
}
