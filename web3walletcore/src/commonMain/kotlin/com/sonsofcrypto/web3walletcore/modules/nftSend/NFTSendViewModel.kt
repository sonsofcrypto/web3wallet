package com.sonsofcrypto.web3walletcore.modules.nftSend

import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkAddressPickerViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkFeeViewModel
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

data class NFTSendViewModel(
    val title: String,
    val items: List<Item>,
) {

    sealed class Item {
        data class Nft(val data: NFTItem): Item()
        data class Address(val data: NetworkAddressPickerViewModel): Item()
        data class Send(val networkFee: NetworkFeeViewModel, val buttonState: ButtonState): Item()
    }

    enum class ButtonState { INVALID_DESTINATION, READY }
}
