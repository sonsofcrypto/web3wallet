package com.sonsofcrypto.web3walletcore.modules.currencySend

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationWireframeContext

data class CurrencySendWireframeContext(
    val network: Network,
    val address: String?,
    val currency: Currency?,
)

sealed class CurrencySendWireframeDestination {
    object UnderConstructionAlert: CurrencySendWireframeDestination()
    data class QrCodeScan(val onCompletion: (String) -> Unit): CurrencySendWireframeDestination()
    data class SelectCurrency(
        val onCompletion: (Currency) -> Unit
    ): CurrencySendWireframeDestination()
    data class ConfirmSend(
        val context: ConfirmationWireframeContext.Send
        ): CurrencySendWireframeDestination()
    object Back: CurrencySendWireframeDestination()
    object Dismiss: CurrencySendWireframeDestination()
}

interface CurrencySendWireframe {
    fun present()
    fun navigate(destination: CurrencySendWireframeDestination)
}
