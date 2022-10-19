package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.BigInt

data class CurrencyFormatterViewModel(
    val amount: BigInt?,
    val currency: Currency,
) {
    fun toOutput(style: Formatters.Style): List<Formatters.Output> =
        Formatters.currency.format(amount, currency, style)
}