package com.sonsofcrypto.web3walletcore.modules.currencyPicker

import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsWireframeDestination

sealed class CurrencyPickerWireframeDestination {
    /** Navigate to add a custom currency to a given network */
    data class AddCustomCurrency(val network: Network): CurrencyPickerWireframeDestination()
    /** Dismiss proposals wireframe */
    object Dismiss: CurrencyPickerWireframeDestination()
}

interface CurrencyPickerWireframe {
    fun present()
    fun navigate(destination: CurrencyPickerWireframeDestination)
}
