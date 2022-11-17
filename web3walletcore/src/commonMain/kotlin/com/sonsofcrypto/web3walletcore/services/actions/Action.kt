package com.sonsofcrypto.web3walletcore.services.actions

import com.sonsofcrypto.web3walletcore.services.actions.Action.Type.*

data class Action(
    val type: Type,
    val imageName: String, // Security, Social, etc
    val title: String,
    val body: String,
    val deepLink: String,
    val canDismiss: Boolean,
    val order: Int, // 1, 2, 3, 4...(left to right)
) {
    sealed class Type {
        data class ConfirmMnemonic(val address: String): Type()
        object Themes: Type()
        object ImprovementProposals: Type()

        val identifier: String get() = when (this) {
            is ConfirmMnemonic -> "modal.mnemonic.confirmation.${address}"
            is Themes -> "settings.themes"
            is ImprovementProposals -> "modal.improvementProposals"
        }
    }
}