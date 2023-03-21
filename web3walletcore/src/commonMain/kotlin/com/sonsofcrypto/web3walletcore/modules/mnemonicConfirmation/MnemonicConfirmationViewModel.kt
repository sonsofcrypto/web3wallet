package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3walletcore.common.viewModels.MnemonicWordInfo

data class MnemonicConfirmationViewModel(
    val potentialWords: List<String>,
    val wordsInfo: List<MnemonicWordInfo>,
    val isValid: Boolean?,
    val mnemonicToUpdate : String?,
    val showSalt: Boolean,
)
