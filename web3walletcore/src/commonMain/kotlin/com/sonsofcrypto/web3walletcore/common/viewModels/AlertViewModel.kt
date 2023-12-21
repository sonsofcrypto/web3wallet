package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.CANCEL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.NORMAL
import com.sonsofcrypto.web3walletcore.extensions.Localized

sealed class AlertViewModel(
    open val title: String,
    open val body: String,
    open val actions: List<Action>,
    open val imageMedia: ImageMedia? = null,
) {

    data class RegularAlertViewModel(
        override val title: String,
        override val body: String,
        override val actions: List<Action> = listOf(
            Action(Localized("Done"), NORMAL),
            Action(Localized("Cancel"), CANCEL),
        ),
        override val imageMedia: ImageMedia? = null,
    ): AlertViewModel(title, body, actions, imageMedia)

    data class InputAlertViewModel(
        override val title: String,
        override val body: String = "",
        val inputText: String = "",
        val inputPlaceholder: String = "",
        override val actions: List<Action> = listOf(
            Action(Localized("Done"), NORMAL),
            Action(Localized("Cancel"), CANCEL),
        ),
        override val imageMedia: ImageMedia? = null,
    ): AlertViewModel(title, body, actions, imageMedia)

    data class LoadingImageAlertViewModel(
        override val title: String,
        override val body: String,
        override val actions: List<Action> = listOf(),
        override val imageMedia: ImageMedia? = null,
    ): AlertViewModel(title, body, actions, imageMedia)

    data class Action(
        val title: String,
        val kind: Kind
    ) {
        enum class Kind { NORMAL, CANCEL, DESTRUCTIVE }
    }
}