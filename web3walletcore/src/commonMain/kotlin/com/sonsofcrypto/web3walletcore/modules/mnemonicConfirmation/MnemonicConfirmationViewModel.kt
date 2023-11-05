package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicInputViewModel


data class MnemonicConfirmationViewModel(
    val potentialWords: List<String>,
    val wordsInfo: List<MnemonicInputViewModel.Word>,
    val isValid: Boolean?,
    val mnemonicToUpdate : String?,
    val showSalt: Boolean,
)
