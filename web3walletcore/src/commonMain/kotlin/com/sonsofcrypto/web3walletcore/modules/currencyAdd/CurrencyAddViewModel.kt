package com.sonsofcrypto.web3walletcore.modules.currencyAdd

data class CurrencyAddViewModel(
    val title : String,
    val network : NetworkItem,
    val contractAddress: TextFieldItem,
    val name: TextFieldItem,
    val symbol: TextFieldItem,
    val decimals: TextFieldItem,
    val saveButtonTitle: String,
    val saveButtonEnabled: Boolean,
) {
    data class NetworkItem(
        val name: String,
        val value: String?,
    )

    data class TextFieldItem(
        val name: String,
        val value: String?,
        val placeholder: String,
        val hint: String?,
        val type: TextFieldType,
        val isFirstResponder: Boolean,
    )

    enum class TextFieldType { CONTRACT_ADDRESS, NAME, SYMBOL, DECIMALS }
}
