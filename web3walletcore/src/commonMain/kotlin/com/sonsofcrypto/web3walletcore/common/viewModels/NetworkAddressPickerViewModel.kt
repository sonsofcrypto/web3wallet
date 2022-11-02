package com.sonsofcrypto.web3walletcore.common.viewModels

data class NetworkAddressPickerViewModel(
    val placeholder: String,
    val value: String?,
    val isValid: Boolean,
    val becomeFirstResponder: Boolean,
)