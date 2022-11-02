package com.sonsofcrypto.web3walletcore.modules.currencySend

import com.sonsofcrypto.web3walletcore.common.viewModels.CurrencyAmountPickerViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkAddressPickerViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkFeeViewModel

data class CurrencySendViewModel(
    val title: String,
    val items: List<Item>,
) {
    sealed class Item {
        data class Address(val data: NetworkAddressPickerViewModel): Item()
        data class Currency(val data: CurrencyAmountPickerViewModel): Item()
        data class Send(val data: SendViewModel): Item()
    }

    data class SendViewModel(
        val networkFee: NetworkFeeViewModel,
        val buttonState: ButtonState,
    )

    enum class ButtonState { INVALID_DESTINATION, ENTER_FUNDS, INSUFFICIENT_FUNDS, READY }
}
