package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel

data class SignersViewModel(
    val isEmpty: Boolean,
    val state: State,
    val items: List<Item>,
    val selectedIdxs: List<Int>,
    val buttons: List<ButtonViewModel>,
    val expandedButtons: List<ButtonViewModel>,
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

    sealed class TransitionTargetView {
        data class KeyStoreItemAt(val idx: Int): TransitionTargetView()
        data class ButtonAt(val idx: Int): TransitionTargetView()
        object None: TransitionTargetView()
    }
}
