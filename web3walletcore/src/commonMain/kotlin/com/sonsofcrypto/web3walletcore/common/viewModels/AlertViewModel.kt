package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.CANCEL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.NORMAL
import com.sonsofcrypto.web3walletcore.extensions.Localized

sealed class AlertViewModel() {

    data class RegularAlertViewModel(
        val title: String,
        val body: String,
        val actions: List<Action> = listOf(
            Action(Localized("Done"), NORMAL),
            Action(Localized("Cancel"), CANCEL),
        ),
        val imageMedia: ImageMedia? = null,
    ): AlertViewModel()

    data class InputAlertViewModel(
        val title: String,
        val body: String = "",
        val inputText: String = "",
        val inputPlaceholde: String = "",
        val actions: List<Action> = listOf(
            Action(Localized("Done"), NORMAL),
            Action(Localized("Cancel"), CANCEL),
        ),
        val imageMedia: ImageMedia? = null,
    )


    data class Action(
        val title: String,
        val kind: Kind
    ) {
        enum class Kind { NORMAL, CANCEL, DESTRUCTIVE }
    }
}