package com.sonsofcrypto.web3walletcore.modules.currencyPicker

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network

data class CurrencyPickerWireframeContext(
    /** True to allow selection of multiple currencies. */
    val isMultiSelect: Boolean,
    /** True when we want to have the option to navigate to AddCustomCurrency module. */
    val showAddCustomCurrency: Boolean,
    /** List of network data to pick from. */
    val networksData: List<NetworkData>,
    /** Optional network to be selected when loading the module. If null, we will auto-select the
     *  first network in networkDatas list. */
    val selectedNetwork: Network? = null,
    /** Callback with selected results. This will be called once on view will disappear. */
    val handler: (List<Result>) -> Unit
) {
    data class NetworkData(
        /** Network. */
        val network: Network,
        /** List of favourite currencies for the given network, in case of multiSelect, those
         *  would automatically be selected (on load). In case of null, we will load the currencies
         *  selected by the user in his/her selected wallet. */
        val favouriteCurrencies: List<Currency>?,
        /** List of currencies for the given network, if not provided we will show all the
         *  supported currencies for the given Network (first 1000 based on rank, and when
         *  the user starts searching we will return the first 1000 matching the term). */
        val currencies: List<Currency>?,
    )

    data class Result(
        /** Selected Network */
        val network: Network,
        /** Selected Currency or Currencies on the selected Network*/
        val selectedCurrencies: List<Currency>,
    )
}

sealed class CurrencyPickerWireframeDestination {
    /** Navigate to AddCustomCurrency module for a given network */
    data class AddCustomCurrency(val network: Network): CurrencyPickerWireframeDestination()
    /** Dismiss module */
    object Dismiss: CurrencyPickerWireframeDestination()
}

interface CurrencyPickerWireframe {
    /** Present module */
    fun present()
    /** Navigate to a new destination */
    fun navigate(destination: CurrencyPickerWireframeDestination)
}
