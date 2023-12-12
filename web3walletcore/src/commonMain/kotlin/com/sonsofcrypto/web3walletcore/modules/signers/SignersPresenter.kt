package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.Type.MNEMONIC
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.execDelayed
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.common.viewModels.BarButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.PRIMARY
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.SECONDARY
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateData
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.ButtonAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.EditAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.CopyAddress
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.ErrorAlertAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SetCTASheet
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SignerAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.ReorderAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SetSearchTerm
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.SwipeOptionAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersPresenterEvent.RightBarButtonAction
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item.SwipeOption
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item.SwipeOption.Kind.ADD
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item.SwipeOption.Kind.COPY
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item.SwipeOption.Kind.HIDE
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.Item.SwipeOption.Kind.SHOW
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.State.Loaded
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.TransitionTargetView.ButtonAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.TransitionTargetView.SignerAt
import com.sonsofcrypto.web3walletcore.modules.signers.SignersViewModel.TransitionTargetView.None
import com.sonsofcrypto.web3walletcore.modules.signers.SignersWireframeDestination.Authenticate
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
import kotlin.time.Duration.Companion.seconds

sealed class SignersPresenterEvent {
    data class SignerAction(val idx: Int): SignersPresenterEvent()
    data class CopyAddress(val idx: Int): SignersPresenterEvent()
    data class EditAction(val idx: Int): SignersPresenterEvent()
    data class SwipeOptionAction(val itemIdx: Int, val actionIdx: Int): SignersPresenterEvent()
    data class ReorderAction(val oldIdx: Int, val newIdx: Int): SignersPresenterEvent()
    data class SetSearchTerm(val term: String?): SignersPresenterEvent()
    data class ErrorAlertAction(val idx: Int): SignersPresenterEvent()
    data class RightBarButtonAction(val idx: Int): SignersPresenterEvent()
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
            is SignerAction -> handleDidSelectSignerStoreItem(event.idx)
            is EditAction -> handleEditAction(event.idx)
            is CopyAddress -> handleCopyAddress(event.idx)
            is SwipeOptionAction ->
                handleSwipeOptionAction(event.itemIdx, event.actionIdx)
            is ReorderAction -> handleReorderAction(event.oldIdx, event.newIdx)
            is SetSearchTerm -> handleSetSearchTerm(event.term)
            is ErrorAlertAction -> handleDidSelectErrorAction(event.idx)
            is RightBarButtonAction -> handleRightBarButtonAction(event.idx)
            is ButtonAction -> handleButtonAction(event.idx)
            is SetCTASheet -> ctaSheetExpanded = event.expanded
        }
    }

    private fun handleDidSelectSignerStoreItem(idx: Int) {
        interactor.selected = interactor.signer(idx)
        updateView()
        wireframe.navigate(Networks)
    }

    private fun handleEditAction(idx: Int) {
        targetView = SignerAt(idx)
        view.get()?.updateTargetView(targetView)
        wireframe.navigate(
            EditSignersItem(
                interactor.signer(idx),
                updateHandler = {
                    val newIdx = interactor.indexOf(it)
                    if (newIdx != -1) { targetView = SignerAt(newIdx) }
                    updateView()
                },
                addAccountHandler = { updateView() },
                deleteHandler = {
                    targetView = None
                    if (interactor.signersCount() == 0) {
                        wireframe.navigate(SignersFullscreen)
                    }
                    present()
                }
            )
        )
    }

    private fun handleSwipeOptionAction(itemIdx: Int, actionIdx: Int) =
        when (swipeOption(itemIdx)[actionIdx].kind) {
            HIDE, SHOW -> handleToggleHidden(itemIdx)
            SwipeOption.Kind.COPY -> handleCopyAddress(itemIdx)
            SwipeOption.Kind.ADD -> handleAddAccountAction(itemIdx)
        }

    private fun handleToggleHidden(idx: Int) =
        interactor.setHidden(interactor.isHidden(idx), idx)

    private fun handleCopyAddress(idx: Int) =
        interactor.address(idx)

    private fun handleAddAccountAction(idx: Int) {
        val item = interactor.signer(idx)
        val title = Localized("authenticate.title.unlock")
        val cxt = AuthenticateWireframeContext(title, item) { auth, err ->
            handleAuthForAddAccount(item, auth, err)
        }
        wireframe.navigate(Authenticate(cxt))
    }

    private fun handleAuthForAddAccount(
        item: SignerStoreItem,
        auth: AuthenticateData?,
        err: Error?
    ) {
        if (auth == null || err != null) { return }
        interactor.addAccount(item, auth.password, auth.salt)
        updateView()
    }

    private fun handleReorderAction(oldIdx: Int, newIdx: Int) {
        interactor.reorderSigner(oldIdx, newIdx)
        updateView()
    }

    private fun handleSetSearchTerm(term: String?) {
        interactor.searchTerm = term
        updateView()
    }

    private fun handleDidSelectErrorAction(idx: Int) = updateView()

    private fun handleRightBarButtonAction(idx: Int) {
        interactor.showHidden != interactor.showHidden
        updateView()
    }

    private fun handleButtonAction(idx: Int) {
        targetView = ButtonAt(idx)
        view.get()?.updateTargetView(targetView)
        when (idx) {
            0 -> wireframe.navigate(NewMnemonic { handleNewSigner(it) })
            1 -> wireframe.navigate(ImportMnemonic { handleNewSigner(it)})
            2 -> if (ctaSheetExpanded) wireframe.navigate(ImportPrivateKey)
                else view.get()?.updateCTASheet(!ctaSheetExpanded)
            3 -> wireframe.navigate(ImportAddress)
            4 -> wireframe.navigate(ConnectHardwareWallet)
            5 -> wireframe.navigate(CreateMultisig)
        }
    }

    private fun handleNewSigner(signerStoreItem: SignerStoreItem) {
        interactor.selected = signerStoreItem
        val idx = interactor.indexOf(signerStoreItem)
        if (idx != -1) { targetView = SignerAt(idx) }
        updateView()
        targetView = None
        navigateToDashboardIfNeeded()
    }

    private fun navigateToDashboardIfNeeded() {
        if (interactor.signersCount() != 1) return
        // HACK: This is non ideal, but since we don't have `viewDidAppear`
        // simply animate to dashboard after first wallet was created
        execDelayed(1.2.seconds) { wireframe.navigate(DashboardOnboarding) }
    }

    private fun updateView(state: SignersViewModel.State = Loaded) {
        view.get()?.update(viewModel(state))
        initialPresent = false
    }

    @OptIn(ExperimentalStdlibApi::class)
    private fun viewModel(state: SignersViewModel.State): SignersViewModel =
        SignersViewModel(
            interactor.signersCount() == 0,
            state,
            listOf(
                BarButtonViewModel(
                    null,
                    SysName(if (interactor.showHidden) "eye.slash" else "eye"),
                    interactor.hiddenSignersCount() == 0,
                ),
            ),
            (0..<interactor.signersCount()).map { itemViewModel(it) },
            listOf(selectedIdxs()).filterNotNull(),
            buttonsCompact(),
            buttonsExpanded(),
            targetView,
        )

    private fun itemViewModel(idx: Int): Item = Item(
        interactor.name(idx),
        interactor.address(idx, true),
        swipeOption(idx),
        interactor.isHidden(idx)
    )


    private fun swipeOption(idx: Int): List<SwipeOption> = listOf(
        SwipeOption(ADD),
        SwipeOption(COPY),
        SwipeOption(if (interactor.isHidden(idx)) HIDE else SHOW)
    ).subList(
        fromIndex = if (interactor.isMnemonicSigner(idx)) 1 else 0,
        toIndex = 3
    )


    private fun selectedIdxs(): Int? {
        val index = interactor.indexOf(interactor.selected)
        if (index != -1) return index
        // If we have items and the keystore item could not tell us which one is
        // selected we default to 0, this should not happen though!
        return if (interactor.signersCount() == 0) null else 0
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
