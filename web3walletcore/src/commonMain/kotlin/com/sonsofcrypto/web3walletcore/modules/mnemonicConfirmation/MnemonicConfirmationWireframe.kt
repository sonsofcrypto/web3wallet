package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

interface MnemonicConfirmationWireframe {
    fun present()
    fun navigate(destination: MnemonicConfirmationWireframeDestination)
}

sealed class MnemonicConfirmationWireframeDestination {
    object Dismiss: MnemonicConfirmationWireframeDestination()
}
