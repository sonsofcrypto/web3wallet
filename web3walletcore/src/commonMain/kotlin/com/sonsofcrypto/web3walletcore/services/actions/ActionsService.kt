package com.sonsofcrypto.web3walletcore.services.actions

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3walletcore.services.actions.Action.Type.*

interface ActionsServiceListener {
    /** This will be called each time the list of Actions changes. */
    fun actionsUpdated()
}

interface ActionsService {
    /** Add a listener to the service */
    fun addListener(listener: ActionsServiceListener)
    /** Remove a listener from the service */
    fun removeListener(listener: ActionsServiceListener)
    /** Complete an action */
    fun completeActionType(type: Action.Type)
    /** List of actions yet to be completed */
    fun outstandingActions(): List<Action>
}

class DefaultActionsService(
    private val store: KeyValueStore,
    private val networksService: NetworksService,
): ActionsService {
    private var listeners = mutableListOf<ActionsServiceListener>()

    override fun addListener(listener: ActionsServiceListener) {
        listeners.add(listener)
    }

    override fun removeListener(listener: ActionsServiceListener) {
        listeners.remove(listener)
    }

    override fun completeActionType(type: Action.Type) {
        if (isActionCompleted(type)) return
        store[type.identifier] = true
        listeners.forEach { it.actionsUpdated() }
    }

    override fun outstandingActions(): List<Action> {
        val actions = mutableListOf<Action>()
        confirmMnemonicAction?.let { if (!isActionCompleted(it.type)) { actions.add(it) } }
        actions.add(themesAction)
        actions.add(improvementProposalsAction)
        return actions
    }

    private fun isActionCompleted(type: Action.Type): Boolean = store[type.identifier] ?: false

    private val confirmMnemonicAction: Action? get() {
        val address = selectedWalletAddress() ?: return null
        return Action(
            ConfirmMnemonic(address),
            "s",
            "Mnemonic",
            "Confirm your mnemonic",
            "modal.mnemonic.confirmation",
            false,
            1
        )
    }

    private fun selectedWalletAddress(): String? = networksService.wallet()?.id()

    private val themesAction: Action get() = Action(
        ImprovementProposals,
        "t",
        "App Themes",
        "Fancy a new look?",
        "settings.themes",
        false,
        2,
    )

    private val improvementProposalsAction: Action get() = Action(
        ImprovementProposals,
        "f",
        "App Features",
        "Your opinion matters to us",
        "modal.improvementProposals",
        false,
        3,
    )
}