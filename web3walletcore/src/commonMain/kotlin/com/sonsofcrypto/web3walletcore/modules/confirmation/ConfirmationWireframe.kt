package com.sonsofcrypto.web3walletcore.modules.confirmation

interface ConfirmationWireframe {
    fun present()
    fun navigate(destination: ConfirmationWireframeDestination)
}

sealed class ConfirmationWireframeDestination {
    data class authenticate(val context: AuthenticateContext): ConfirmationWireframeDestination()
    object underConstruction: ConfirmationWireframeDestination()
    object account: ConfirmationWireframeDestination()
    object nftsDashboard: ConfirmationWireframeDestination()
    object cultProposals: ConfirmationWireframeDestination()
    data class viewEtherscan(val txHash: String): ConfirmationWireframeDestination()
    data class report(val error: String): ConfirmationWireframeDestination()
}
