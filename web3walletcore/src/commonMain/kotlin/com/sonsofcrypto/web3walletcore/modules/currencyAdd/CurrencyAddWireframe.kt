package com.sonsofcrypto.web3walletcore.modules.currencyAdd

import com.sonsofcrypto.web3lib.types.Network

data class CurrencyAddWireframeContext(
    /** Network to receive crypto */
    val network: Network,
)

sealed class CurrencyAddWireframeDestination {
    /** Select network */
    data class NetworkPicker(val handler: (Network) -> Unit): CurrencyAddWireframeDestination()
    /** Dismiss module */
    object Dismiss: CurrencyAddWireframeDestination()
}

interface CurrencyAddWireframe {
    /** Present module */
    fun present()
    /** Navigate to a new destination module */
    fun navigate(destination: CurrencyAddWireframeDestination)
}