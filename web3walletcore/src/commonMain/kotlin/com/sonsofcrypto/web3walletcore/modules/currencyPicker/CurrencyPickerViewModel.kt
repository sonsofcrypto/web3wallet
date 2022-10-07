package com.sonsofcrypto.web3walletcore.modules.currencyPicker

import com.sonsofcrypto.web3walletcore.extensions.Localized

data class CurrencyPickerViewModel(
    val title: String,
    val allowMultipleSelection: Boolean,
    val showAddCustomCurrency: Boolean,
    val content: List<Section>,
) {
    sealed class Section(
        val name: String,
    ) {
        data class Networks(
            val items: List<Network>
        ): Section(Localized("currencyPicker.networks.title"))

        data class Currencies(
            val items: List<Currency>
        ): Section(Localized("currencyPicker.currencies.title"))
    }

    data class Network(
        val networkId: String,
        val iconName: String,
        val name: String,
        val isSelected: Boolean,
    )

    data class Currency(
        val id: String,
        val imageName: String,
        val symbol: String,
        val name: String,
        val position: Position,
        val isSelected: Boolean?,
        val tokens: String? = null,
        val fiat: String? = null,
    )

    enum class Position {
        SINGLE, FIRST, MIDDLE, LAST
    }
}