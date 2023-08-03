package com.sonsofcrypto.web3walletcore.modules.currencyReceive

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network

data class CurrencyReceiveWireframeContext(
    /** Network to receive crypto */
    val network: Network,
    /** Currency to receive crypto */
    val currency: Currency,
)

sealed class CurrencyReceiveWireframeDestination {
    /** Dismiss module */
    object Back: CurrencyReceiveWireframeDestination()
    object Dismiss: CurrencyReceiveWireframeDestination()
}

interface CurrencyReceiveWireframe {
    /** Present module */
    fun present()
    /** Navigate to a new destination module */
    fun navigate(destination: CurrencyReceiveWireframeDestination)
}