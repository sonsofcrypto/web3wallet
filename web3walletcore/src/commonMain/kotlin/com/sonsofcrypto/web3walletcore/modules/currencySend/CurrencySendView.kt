package com.sonsofcrypto.web3walletcore.modules.currencySend

import com.sonsofcrypto.web3lib.types.NetworkFee

interface CurrencySendView {
    fun update(viewModel: CurrencySendViewModel)
    fun presentNetworkFeePicker(networkFees: List<NetworkFee>, selected: NetworkFee?)
    fun dismissKeyboard()
}
