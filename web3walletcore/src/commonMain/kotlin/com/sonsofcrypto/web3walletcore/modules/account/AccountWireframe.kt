package com.sonsofcrypto.web3walletcore.modules.account

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network

data class AccountWireframeContext(
    val network: Network,
    val currency: Currency,
)

sealed class AccountWireframeDestination {
    object Receive: AccountWireframeDestination()
    object Send: AccountWireframeDestination()
    object Swap: AccountWireframeDestination()
    object More: AccountWireframeDestination()
}

interface AccountWireframe {
    fun present()
    fun navigate(destination: AccountWireframeDestination)
}