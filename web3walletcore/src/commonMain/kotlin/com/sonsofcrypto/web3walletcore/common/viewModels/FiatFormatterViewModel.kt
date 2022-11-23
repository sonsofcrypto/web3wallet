package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.utils.BigDec

// TODO(Sancho): Kill it
data class FiatFormatterViewModel(
    val amount: BigDec?,
    val currencyCode: String = "usd",
) {
    fun toOutput(style: Formatters.Style): List<Formatters.Output> =
        Formatters.fiat.format(amount, style, currencyCode)
}