package com.sonsofcrypto.web3walletcore.modules.currencyAdd

import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerViewModel

interface CurrencyAddView {
    fun update(viewModel: CurrencyAddViewModel)
    fun dismissKeyboard()
}