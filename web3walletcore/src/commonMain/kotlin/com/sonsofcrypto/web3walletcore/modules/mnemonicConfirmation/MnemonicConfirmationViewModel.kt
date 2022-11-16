package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

data class MnemonicConfirmationViewModel(
    val potentialWords: List<String>,
    val wordsInfo: List<WordInfo>,
    val isValid: Boolean?,
    val mnemonicToUpdate : String?,
    val showSalt: Boolean,
) {
    data class WordInfo(
        val word: String,
        val isInvalid: Boolean,
    )
}
