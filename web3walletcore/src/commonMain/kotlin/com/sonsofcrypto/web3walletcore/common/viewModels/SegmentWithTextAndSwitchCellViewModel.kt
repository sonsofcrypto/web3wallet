package com.sonsofcrypto.web3walletcore.common.viewModels

class SegmentWithTextAndSwitchCellViewModel(
    val title: String,
    val segmentOptions: List<String>,
    val selectedSegment: Int,
    val password: String,
    val passwordKeyboardType: KeyboardType, // move to not UIKit...,
    val placeholder: String,
    val errorMessage: String?,
    val onOffTitle: String,
    val onOff: Boolean,
) {
    enum class KeyboardType { DEFAULT, NUMBER_PAD }

    val hasHint: Boolean get() = errorMessage != null
}