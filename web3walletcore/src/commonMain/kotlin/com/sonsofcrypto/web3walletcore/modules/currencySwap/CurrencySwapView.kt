package com.sonsofcrypto.web3walletcore.modules.currencySwap

import com.sonsofcrypto.web3lib.types.NetworkFee

interface CurrencySwapView {
    fun update(viewModel: CurrencySwapViewModel)
    fun presentNetworkFeePicker(networkFees: List<NetworkFee>)
}
