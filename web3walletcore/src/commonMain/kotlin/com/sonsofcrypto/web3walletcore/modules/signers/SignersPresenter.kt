package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.PRIMARY
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.SECONDARY
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.AccessoryAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.ButtonAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.ErrorAlertAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SetCTASheet
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SignerAction
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
    data class SignerAction(val idx: Int): SignersPresenterEvent()
    data class AccessoryAction(val idx: Int): SignersPresenterEvent()
    data class ErrorAlertAction(val idx: Int): SignersPresenterEvent()
    data class ButtonAction(val idx: Int): SignersPresenterEvent()
    data class SetCTASheet(val expanded: Boolean): SignersPresenterEvent()
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
    private var ctaSheetExpanded: Boolean = false
    private var targetView: SignersViewModel.TransitionTargetView = None
    private var initialPresent: Boolean = true

    override fun present() { updateView() }

    override fun handle(event: SignersPresenterEvent) {
        when (event) {
            is SignerAction -> handleDidSelectKeyStoreItem(event.idx)
            is AccessoryAction -> handleDidSelectAccessory(event.idx)
            is ErrorAlertAction -> handleDidSelectErrorAction(event.idx)
            is ButtonAction -> handleButtonAction(event.idx)
            is SetCTASheet -> ctaSheetExpanded = event.expanded
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
        when (idx) {
            0 -> wireframe.navigate(NewMnemonic { handleNewKeyStoreItem(it) })
            1 -> wireframe.navigate(ImportMnemonic { handleNewKeyStoreItem(it)})
            2 -> if (ctaSheetExpanded) wireframe.navigate(ImportPrivateKey)
                else view.get()?.updateCTASheet(!ctaSheetExpanded)
            3 -> wireframe.navigate(ImportAddress)
            4 -> wireframe.navigate(ConnectHardwareWallet)
            5 -> wireframe.navigate(CreateMultisig)
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
            buttonsCompact(),
            buttonsExpanded(),
            targetView,
        )

    private fun selectedIdxs(): Int? {
        val index = interactor.items.indexOfFirst { it == interactor.selected }
        if (index != -1) return index
        // If we have items and the keystore item could not tell us which one is
        // selected we default to 0, this should not happen though!
        return if (interactor.items.isEmpty()) null else 0
    }

    private fun buttonsCompact(): List<ButtonViewModel> = listOf(
        ButtonViewModel(Localized("keyStore.newMnemonic"), PRIMARY),
        ButtonViewModel(Localized("keyStore.importMnemonic"), SECONDARY),
        ButtonViewModel(Localized("keyStore.moreOption"), SECONDARY),
        ButtonViewModel(Localized("keyStore.importAddress"), SECONDARY),
        ButtonViewModel(Localized("keyStore.connectHardwareWallet"), SECONDARY),
        ButtonViewModel(Localized("keyStore.createMultiSig"), SECONDARY)
    )

    private fun buttonsExpanded(): List<ButtonViewModel> = listOf(
        ButtonViewModel(Localized("keyStore.newMnemonic"), PRIMARY),
        ButtonViewModel(Localized("keyStore.importMnemonic"), SECONDARY),
        ButtonViewModel(Localized("keyStore.importPrivateKey"), SECONDARY),
        ButtonViewModel(Localized("keyStore.importAddress"), SECONDARY),
        ButtonViewModel(Localized("keyStore.connectHardwareWallet"), SECONDARY),
        ButtonViewModel(Localized("keyStore.createMultiSig"), SECONDARY)
    )

    private fun formattedAddress(signerStoreItem: SignerStoreItem): String? {
        // TODO: Review here when supporting other networks
        val address = signerStoreItem.addresses[signerStoreItem.derivationPath]
            ?: return null
        return Formatters.address.format(address, 10, Network.ethereum())
    }
}

