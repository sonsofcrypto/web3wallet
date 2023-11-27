package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel.Position.TOP

class ToastViewModel(
    val text: String,
    val media: ImageMedia?,
    val position: Position = TOP,
) {
   enum class Position {
       TOP, BOTTOM
   }
}
