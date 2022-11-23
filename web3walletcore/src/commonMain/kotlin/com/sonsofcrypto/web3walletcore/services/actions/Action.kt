package com.sonsofcrypto.web3walletcore.services.actions

import com.sonsofcrypto.web3walletcore.extensions.Localized

sealed class Action(
    val title: String,
    val body: String,
    val imageName: String,
) {

    object ConfirmMnemonic: Action(
        Localized("actions.mnemonic.title"),
        Localized("actions.mnemonic.body"),
        "s",
    )

    object Themes: Action(
        Localized("actions.themes.title"),
        Localized("actions.themes.body"),
        "t",
    )

    object ImprovementProposals: Action(
        Localized("actions.improvementProposals.title"),
        Localized("actions.improvementProposals.body"),
        "i",
    )
}