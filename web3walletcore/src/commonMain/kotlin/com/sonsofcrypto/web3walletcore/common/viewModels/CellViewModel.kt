package com.sonsofcrypto.web3walletcore.common.viewModels

sealed class CellViewModel {
    enum class Accessory {
        NONE, DETAIL, CHECKMARK, COPY
    }

    data class Label(
        val text: String,
        val accessory: Accessory = Accessory.NONE,
        val selected: Boolean = false,
        val trailingText: String? = null,
    ): CellViewModel()

    data class Text(val text: String?): CellViewModel()

    data class TextInput(
        val title: String,
        val value: String,
        val placeholder: String,
    ): CellViewModel()

    data class SwitchTextInput(
        val title: String,
        val onOff: Boolean,
        val text: String,
        val placeholder: String,
        val description: String,
        val descriptionHighlightedWords: List<String>,
    ): CellViewModel()

    data class Switch(
        val title: String,
        val onOff: Boolean,
    ): CellViewModel()

    data class SegmentSelection(
        val title: String,
        val values: List<String>,
        val selectedIdx: Int,
    ): CellViewModel()

    data class SegmentWithTextAndSwitch(
        val title: String,
        val segmentOptions: List<String>,
        val selectedSegment: Int,
        val password: String,
        val passwordKeyboardType: KeyboardType,
        val placeholder: String,
        val errorMessage: String?,
        val onOffTitle: String,
        val onOff: Boolean,
    ): CellViewModel() {
        enum class KeyboardType { DEFAULT, NUMBER_PAD }
        val hasHint: Boolean get() = errorMessage != null
    }
    
    data class Button(
        val title: String,
        val type: ButtonType
    ): CellViewModel() {
        enum class ButtonType { PRIMARY, SECONDARY, DESTRUCTIVE }
    }

    data class KeyValueList(
        val items: List<Item>,
        val userInfo: Map<String, Any>? = null
    ): CellViewModel() {
        data class Item(
            val key: String,
            val value: String,
            val placeholder: String? = null,
            val userInfo: Map<String, Any>? = null
        )
    }
}
