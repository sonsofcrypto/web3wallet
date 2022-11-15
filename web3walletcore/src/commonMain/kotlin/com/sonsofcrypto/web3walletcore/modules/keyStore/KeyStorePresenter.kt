package com.sonsofcrypto.web3walletcore.modules.keyStore

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStorePresenterEvent.*
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.ButtonSheetViewModel.Button
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.ButtonSheetViewModel.Button.Type.*
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.ButtonSheetViewModel.SheetMode
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.ButtonSheetViewModel.SheetMode.COMPACT
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.ButtonSheetViewModel.SheetMode.EXPANDED
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.Item
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.State.Loaded
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel.TransitionTargetView.*
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreWireframeDestination.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class KeyStorePresenterEvent {
    data class DidSelectKeyStoreItemtAt(val idx: Int): KeyStorePresenterEvent()
    data class DidSelectAccessory(val idx: Int): KeyStorePresenterEvent()
    data class DidSelectErrorActionAt(val idx: Int): KeyStorePresenterEvent()
    data class DidSelectButtonAt(val idx: Int): KeyStorePresenterEvent()
    data class DidChangeButtonsSheetMode(val mode: SheetMode): KeyStorePresenterEvent()
}

interface KeyStorePresenter {
    fun present()
    fun handle(event: KeyStorePresenterEvent)
}

class DefaultKeyStorePresenter(
    private val view: WeakRef<KeyStoreView>,
    private val wireframe: KeyStoreWireframe,
    private val interactor: KeyStoreInteractor,
): KeyStorePresenter {
    private var buttonsSheet: KeyStoreViewModel.ButtonSheetViewModel = buttonsCompacted()
    private var targetView: KeyStoreViewModel.TransitionTargetView = None
    private val uiScope = CoroutineScope(uiDispatcher)

    override fun present() { updateView() }

    override fun handle(event: KeyStorePresenterEvent) {
        when (event) {
            is DidSelectKeyStoreItemtAt -> handleDidSelectKeyStoreItem(event.idx)
            is DidSelectAccessory -> handleDidSelectAccessory(event.idx)
            is DidSelectErrorActionAt -> handleDidSelectErrorAction(event.idx)
            is DidSelectButtonAt -> handleButtonAction(event.idx)
            is DidChangeButtonsSheetMode -> handleDidChangeButtonsState(event.mode)
        }
    }

    private fun handleDidSelectKeyStoreItem(idx: Int) {
        val keyStoreItem = interactor.items[idx]
        interactor.selected = keyStoreItem
        updateView()
        wireframe.navigate(Networks)
    }

    private fun handleDidSelectAccessory(idx: Int) {
        targetView = KeyStoreItemAt(idx)
        view.get()?.updateTargetView(targetView)
        val item = interactor.items[idx]
        wireframe.navigate(
            EditKeyStoreItem(
                item,
                handler = {
                    val newIdx = interactor.items.indexOf(it)
                    if (newIdx != -1) { targetView = KeyStoreItemAt(newIdx) }
                    updateView()
                },
                onDeleted = {
                    if (interactor.items.isEmpty()) { wireframe.navigate(HideNetworksAndDashboard) }
                    present()
                }
            )
        )
    }

    private fun handleDidSelectErrorAction(idx: Int) { updateView() }

    private fun handleButtonAction(idx: Int) {
        targetView = ButtonAt(idx)
        view.get()?.updateTargetView(targetView)
        when (buttonsSheet.buttons[idx].type) {
            NEW_MNEMONIC -> wireframe.navigate(
                NewMnemonic { handleDidCreateNewKeyStoreItem(it) }
            )
            IMPORT_MNEMONIC -> wireframe.navigate(
                NewMnemonic { handleDidCreateNewKeyStoreItem(it) }
            )
            MORE_OPTION -> handleDidChangeButtonsState(EXPANDED)
            CONNECT_HARDWARE_WALLET -> wireframe.navigate(ConnectHardwareWallet)
            IMPORT_PRIVATE_KEY -> wireframe.navigate(ImportPrivateKey)
            CREATE_MULTI_SIG -> wireframe.navigate(CreateMultisig)
        }
    }

    private fun handleDidCreateNewKeyStoreItem(keyStoreItem: KeyStoreItem) {
        interactor.selected = keyStoreItem
        val idx = interactor.items.indexOf(keyStoreItem)
        if (idx != -1) { targetView = KeyStoreItemAt(idx) }
        updateView()
        targetView = None
        navigateToDashboardIfNeeded()
    }

    private fun navigateToDashboardIfNeeded() {
        if (interactor.items.count() != 1) return
        // HACK: This is non ideal, but since we dont have `viewDidAppear`
        // simply animate to dashboard after first wallet was created
        uiScope.launch {
            delay(1200.toLong())
            wireframe.navigate(DashboardOnboarding)
        }
    }

    private fun handleDidChangeButtonsState(mode: SheetMode) {
        if (buttonsSheet.mode == mode) return
        if (mode == COMPACT) {
            buttonsSheet = buttonsCompacted()
        } else if (mode == EXPANDED) {
            buttonsSheet = buttonsExpanded()
        }
        updateView()
    }

    private fun updateView(state: KeyStoreViewModel.State = Loaded) {
        view.get()?.update(viewModel(state))
    }

    private fun viewModel(state: KeyStoreViewModel.State): KeyStoreViewModel = KeyStoreViewModel(
        interactor.items.isEmpty(),
        state,
        interactor.items.map { Item(it.name, it.addressFormatted) },
        listOf(selectedIdxs()).mapNotNull { it },
        buttonsSheet,
        targetView
    )

    private fun selectedIdxs(): Int? {
        val index = interactor.items.indexOfFirst { it == interactor.selected }
        if (index != -1) return index
        // If we have items and the keystore item could not tell us which one is selected
        // we default to 0, this should not happen though!
        return if (interactor.items.isEmpty()) null else 0
    }

    private fun buttonsCompacted(): KeyStoreViewModel.ButtonSheetViewModel =
        KeyStoreViewModel.ButtonSheetViewModel(
            listOf(
                Button(Localized("keyStore.newMnemonic"), NEW_MNEMONIC),
                Button(Localized("keyStore.importMnemonic"), IMPORT_MNEMONIC),
                Button(Localized("keyStore.moreOption"), MORE_OPTION),
                Button(Localized("keyStore.importPrivateKey"), IMPORT_PRIVATE_KEY),
                Button(Localized("keyStore.createMultiSig"), CREATE_MULTI_SIG)
            ),
            COMPACT
        )

    private fun buttonsExpanded(): KeyStoreViewModel.ButtonSheetViewModel =
        KeyStoreViewModel.ButtonSheetViewModel(
            listOf(
                Button(Localized("keyStore.newMnemonic"), NEW_MNEMONIC),
                Button(Localized("keyStore.importMnemonic"), IMPORT_MNEMONIC),
                Button(Localized("keyStore.connectHardwareWallet"), CONNECT_HARDWARE_WALLET),
                Button(Localized("keyStore.importPrivateKey"), IMPORT_PRIVATE_KEY),
                Button(Localized("keyStore.createMultiSig"), CREATE_MULTI_SIG)
            ),
            EXPANDED
        )
}

private val KeyStoreItem.addressFormatted: String? get() {
    val address = addresses[derivationPath] ?: return null
    // TODO: Review here when supporting other networks
    return Formatters.networkAddress.format(address, 10, Network.ethereum())
}
