package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext

typealias SignerHandler = (SignerStoreItem) -> Unit

sealed class SignersWireframeDestination {
    object SignersFullscreen: SignersWireframeDestination()
    object Networks: SignersWireframeDestination()
    object Dashboard: SignersWireframeDestination()
    object DashboardOnboarding: SignersWireframeDestination()
    data class NewMnemonic(val handler: SignerHandler): SignersWireframeDestination()
    data class ImportMnemonic(val handler: SignerHandler): SignersWireframeDestination()
    data class ImportPrvKey(val handler: SignerHandler): SignersWireframeDestination()
    data class EditSignersItem(
        val item: SignerStoreItem,
        val updateHandler: (SignerStoreItem) -> Unit,
        val addAccountHandler: () -> Unit,
        val deleteHandler: () -> Unit,
    ): SignersWireframeDestination()
    object ImportAddress: SignersWireframeDestination()
    object ConnectHardwareWallet: SignersWireframeDestination()
    object CreateMultisig: SignersWireframeDestination()
    data class Authenticate(val context: AuthenticateWireframeContext): SignersWireframeDestination()

}

interface SignersWireframe {
    fun present()
    fun navigate(destination: SignersWireframeDestination)
}
