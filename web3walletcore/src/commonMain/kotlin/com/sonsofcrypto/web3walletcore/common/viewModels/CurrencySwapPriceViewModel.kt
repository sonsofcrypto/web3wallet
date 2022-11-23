package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3lib.formatters.Formatters

// TODO(Sancho): Struct with just one value is needles by definition
data class CurrencySwapPriceViewModel(
    val value: List<Formatters.Output>
)
