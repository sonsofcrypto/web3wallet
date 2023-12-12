package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3walletcore.common.viewModels.BarButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia

data class SignersViewModel(
    val isEmpty: Boolean,
    val state: State,
    val rightBarButtons: List<BarButtonViewModel> = emptyList(),
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
        val swipeOptions: List<SwipeOption>,
        val isHidden: Boolean = false,
    ) {
        data class SwipeOption(
            val kind: Kind,
        ) {
            enum class Kind {
                HIDE, SHOW, COPY, ADD
            }

            fun title(): String = when (kind) {
                Kind.HIDE -> "hide"
                Kind.SHOW -> "show"
                Kind.COPY -> "copyAddress"
                Kind.ADD -> "mnemonic.cta.account"
            }

            fun media(): ImageMedia? = when (kind) {
                Kind.HIDE -> ImageMedia.SysName("eye.slash")
                Kind.SHOW -> ImageMedia.SysName("eye")
                Kind.COPY -> ImageMedia.SysName("square.on.square")
                Kind.ADD -> ImageMedia.SysName("plus")
            }
        }
    }

    sealed class TransitionTargetView {
        data class SignerAt(val idx: Int): TransitionTargetView()
        data class ButtonAt(val idx: Int): TransitionTargetView()
        object None: TransitionTargetView()
    }
}
