package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.utils.BigDec

// TODO(Sancho): This is needless container. What ever viewModel this is using it
// should someProperty: List<Formatters.Output> instead of
// someProperty: CurrencyFormatterViewModel
data class FiatFormatterViewModel(
    val amount: BigDec?,
    val currencyCode: String = "usd",
) {
    fun toOutput(style: Formatters.Style): List<Formatters.Output> =
        Formatters.fiat.format(amount, style, currencyCode)
}