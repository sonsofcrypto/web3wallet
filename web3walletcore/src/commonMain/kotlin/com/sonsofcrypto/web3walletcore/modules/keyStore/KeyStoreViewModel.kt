package com.sonsofcrypto.web3walletcore.modules.keyStore

import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel

data class KeyStoreViewModel(
    val isEmpty: Boolean,
    val state: State,
    val items: List<Item>,
    val selectedIdxs: List<Int>,
    val buttons: ButtonSheetViewModel,
    val targetView: TransitionTargetView,
) {
    sealed class State {
        object Loading: State()
        object Loaded: State()
        data class Error(val error: ErrorViewModel): State()
    }

    data class Item(
        val title: String,
        val address: String?,
    )

    data class ButtonSheetViewModel(
        val buttons: List<Button>,
        val mode: SheetMode,
    ) {
        data class Button(
            val title: String,
            val type: Type,
        ) {
            enum class Type {
                NEW_MNEMONIC,
                IMPORT_MNEMONIC,
                MORE_OPTION,
                CONNECT_HARDWARE_WALLET,
                IMPORT_PRIVATE_KEY,
                CREATE_MULTI_SIG,
            }
        }

        enum class SheetMode { HIDDEN, COMPACT, EXPANDED }
    }

    sealed class TransitionTargetView {
        data class KeyStoreItemAt(val idx: Int): TransitionTargetView()
        data class ButtonAt(val idx: Int): TransitionTargetView()
        object None: TransitionTargetView()
    }
}
