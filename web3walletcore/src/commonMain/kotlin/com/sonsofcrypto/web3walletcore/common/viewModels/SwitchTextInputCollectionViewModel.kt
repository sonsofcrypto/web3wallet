package com.sonsofcrypto.web3walletcore.common.viewModels

data class SwitchTextInputCollectionViewModel(
    val title: String,
    val onOff: Boolean,
    val text: String,
    val placeholder: String,
    val description: String,
    val descriptionHighlightedWords: List<String>,
)
