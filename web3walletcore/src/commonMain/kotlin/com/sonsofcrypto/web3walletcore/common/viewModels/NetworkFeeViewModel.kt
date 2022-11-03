package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3lib.formatters.Formatters

data class NetworkFeeViewModel(
    val name: String,
    val amount: List<Formatters.Output>,
    val time: List<Formatters.Output>,
    val fiat: List<Formatters.Output>,
)