package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.ChangeButtonsSheetMode
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SelectAccessory
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SelectButtonAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SelectErrorActionAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SelectSignerItemAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.CONNECT_HARDWARE_WALLET
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.CREATE_MULTI_SIG
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.IMPORT_ADDRESS
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.IMPORT_MNEMONIC
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.IMPORT_PRIV_KEY
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.MORE_OPTION
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.Button.Type.NEW_MNEMONIC
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.SheetMode
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.SheetMode.COMPACT
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.ButtonSheetViewModel.SheetMode.EXPANDED
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.State.Loaded
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.TransitionTargetView.ButtonAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.TransitionTargetView.KeyStoreItemAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.TransitionTargetView.None
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.ConnectHardwareWallet
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.CreateMultisig
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.DashboardOnboarding
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.EditSignersItem
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.ImportAddress
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.ImportMnemonic
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.ImportPrivateKey
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.Networks
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.NewMnemonic
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.SignersFullscreen
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class SignersPresenterEvent {
    data class SelectSignerItemAt(val idx: Int): SignersPresenterEvent()
    data class SelectAccessory(val idx: Int): SignersPresenterEvent()
    data class SelectErrorActionAt(val idx: Int): SignersPresenterEvent()
    data class SelectButtonAt(val idx: Int): SignersPresenterEvent()
    data class ChangeButtonsSheetMode(val mode: SheetMode): SignersPresenterEvent()
}

interface SignersPresenter {
    fun present()
    fun handle(event: SignersPresenterEvent)
}

class DefaultSignersPresenter(
    private val view: WeakRef<SignersView>,
    private val wireframe: SignersWireframe,
    private val interactor: SignersInteractor,
): SignersPresenter {
    private var buttonsSheet: SignersViewModel.ButtonSheetViewModel = buttonsCompact()
    private var targetView: SignersViewModel.TransitionTargetView = None
    private var initialPresent: Boolean = true

    override fun present() { updateView() }

    override fun handle(event: SignersPresenterEvent) {
        when (event) {
            is SelectSignerItemAt -> handleDidSelectKeyStoreItem(event.idx)
            is SelectAccessory -> handleDidSelectAccessory(event.idx)
            is SelectErrorActionAt -> handleDidSelectErrorAction(event.idx)
            is SelectButtonAt -> handleButtonAction(event.idx)
            is ChangeButtonsSheetMode -> handleDidChangeButtonsState(event.mode)
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
            EditSignersItem(
                item,
                handler = {
                    val newIdx = interactor.items.indexOf(it)
                    if (newIdx != -1) { targetView = KeyStoreItemAt(newIdx) }
                    updateView()
                },
                deleteHandler = {
                    targetView = None
                    if (interactor.items.isEmpty()) {
                        wireframe.navigate(SignersFullscreen)
                    }
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
                NewMnemonic { handleNewKeyStoreItem(it) }
            )
            IMPORT_MNEMONIC -> wireframe.navigate(
                ImportMnemonic { handleNewKeyStoreItem(it) }
            )
            MORE_OPTION -> handleDidChangeButtonsState(EXPANDED)
            IMPORT_PRIV_KEY -> wireframe.navigate(ImportPrivateKey)
            IMPORT_ADDRESS -> wireframe.navigate(ImportAddress)
            CONNECT_HARDWARE_WALLET -> wireframe.navigate(ConnectHardwareWallet)
            CREATE_MULTI_SIG -> wireframe.navigate(CreateMultisig)
        }
    }

    private fun handleNewKeyStoreItem(signerStoreItem: SignerStoreItem) {
        interactor.selected = signerStoreItem
        val idx = interactor.items.indexOf(signerStoreItem)
        if (idx != -1) { targetView = KeyStoreItemAt(idx) }
        updateView()
        targetView = None
        navigateToDashboardIfNeeded()
    }

    private fun navigateToDashboardIfNeeded() {
        if (interactor.items.count() != 1) return
        // HACK: This is non ideal, but since we dont have `viewDidAppear`
        // simply animate to dashboard after first wallet was created
        CoroutineScope(uiDispatcher).launch {
            delay(1200.toLong())
            wireframe.navigate(DashboardOnboarding)
        }
    }

    private fun handleDidChangeButtonsState(mode: SheetMode) {
        if (buttonsSheet.mode == mode) return
        if (mode == COMPACT) {
            buttonsSheet = buttonsCompact()
        } else if (mode == EXPANDED) {
            buttonsSheet = buttonsExpanded()
        }
        updateView()
    }

    private fun updateView(state: SignersViewModel.State = Loaded) {
        view.get()?.update(viewModel(state))
        initialPresent = false
    }

    private fun viewModel(state: SignersViewModel.State): SignersViewModel
        = SignersViewModel(
            interactor.items.isEmpty(),
            state,
            interactor.items.map { Item(it.name, formattedAddress(it)) },
            listOf(selectedIdxs()).filterNotNull(),
            buttonsSheet,
            targetView
        )

    private fun selectedIdxs(): Int? {
        val index = interactor.items.indexOfFirst { it == interactor.selected }
        if (index != -1) return index
        // If we have items and the keystore item could not tell us which one is
        // selected we default to 0, this should not happen though!
        return if (interactor.items.isEmpty()) null else 0
    }

    private fun buttonsCompact(): SignersViewModel.ButtonSheetViewModel =
        SignersViewModel.ButtonSheetViewModel(
            listOf(
                Button(Localized("keyStore.newMnemonic"), NEW_MNEMONIC),
                Button(Localized("keyStore.importMnemonic"), IMPORT_MNEMONIC),
                Button(Localized("keyStore.moreOption"), MORE_OPTION),
                Button(Localized("keyStore.importPublicKey"), IMPORT_ADDRESS),
                Button(Localized("keyStore.connectHardwareWallet"), CONNECT_HARDWARE_WALLET),
                Button(Localized("keyStore.createMultiSig"), CREATE_MULTI_SIG)
            ),
            COMPACT
        )

    private fun buttonsExpanded(): SignersViewModel.ButtonSheetViewModel =
        SignersViewModel.ButtonSheetViewModel(
            listOf(
                Button(Localized("keyStore.newMnemonic"), NEW_MNEMONIC),
                Button(Localized("keyStore.importMnemonic"), IMPORT_MNEMONIC),
                Button(Localized("keyStore.importPrivateKey"), IMPORT_PRIV_KEY),
                Button(Localized("keyStore.importPublicKey"), IMPORT_ADDRESS),
                Button(Localized("keyStore.connectHardwareWallet"), CONNECT_HARDWARE_WALLET),
                Button(Localized("keyStore.createMultiSig"), CREATE_MULTI_SIG)
            ),
            EXPANDED
        )

    private fun formattedAddress(signerStoreItem: SignerStoreItem): String? {
        // TODO: Review here when supporting other networks
        val address = signerStoreItem.addresses[signerStoreItem.derivationPath]
            ?: return null
        return Formatters.networkAddress.format(address, 10, Network.ethereum())
    }
}

