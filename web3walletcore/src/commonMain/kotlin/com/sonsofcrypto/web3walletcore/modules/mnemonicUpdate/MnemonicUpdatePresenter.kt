package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.isValidDerivationPath
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.CANCEL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.NORMAL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.RegularAlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.DESTRUCTIVE
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.SECONDARY
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Button
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Text
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.BarButton
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.AlertAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CTAAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CellButtonAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CopyAccountAddress
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CopyMnemonic
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.RightBarButtonAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetAccountHidden
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetAccountName
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetICouldBackup
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.ViewPrivKey
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeDestination.Alert
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeDestination.Authenticate
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeDestination.Dismiss
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.seconds

sealed class MnemonicUpdatePresenterEvent {
    object Dismiss: MnemonicUpdatePresenterEvent()
    object CopyMnemonic: MnemonicUpdatePresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): MnemonicUpdatePresenterEvent()
    data class SetICouldBackup(val onOff: Boolean): MnemonicUpdatePresenterEvent()
    data class SetAccountHidden(val hidden: Boolean, val idx: Int): MnemonicUpdatePresenterEvent()
    data class CopyAccountAddress(val idx: Int): MnemonicUpdatePresenterEvent()
    data class ViewPrivKey(val idx: Int): MnemonicUpdatePresenterEvent()
    data class CellButtonAction(val idx: Int): MnemonicUpdatePresenterEvent()
    data class AlertAction(val idx: Int, val text: String?): MnemonicUpdatePresenterEvent()
    data class RightBarButtonAction(val idx: Int): MnemonicUpdatePresenterEvent()
    data class CTAAction(val idx: Int): MnemonicUpdatePresenterEvent()
}

interface MnemonicUpdatePresenter {
    fun present()
    fun handle(event: MnemonicUpdatePresenterEvent)
}

class DefaultMnemonicUpdatePresenter(
    private val view: WeakRef<MnemonicUpdateView>,
    private val wireframe: MnemonicUpdateWireframe,
    private val interactor: MnemonicUpdateInteractor,
    private val context: MnemonicUpdateWireframeContext,
): MnemonicUpdatePresenter {
    private var ctaTapped = false
    private var authenticated: Boolean = false
    private var localExpertMode: Boolean = false
    /** -1 alert not presented. Else it is idx of account alert is about */
    private var presentingPrivKeyAlert: Int = -1
    private var presentingCustomDerivationAlert: Boolean = false
    private var presentingDeleteConfirmation: Boolean = false

    override fun present() {
        updateView()
        if (!authenticated) {
            wireframe.navigate(Authenticate(authenticateContext()))
            authenticated = true
        }
    }

    override fun handle(event: MnemonicUpdatePresenterEvent) =  when (event) {
        is MnemonicUpdatePresenterEvent.Dismiss -> dismiss()
        is CopyMnemonic -> interactor.pasteToClipboard(interactor.mnemonic())
        is SetAccountName -> interactor.setAccountName(event.name, event.idx)
        is SetICouldBackup -> interactor.iCloudSecretStorage = event.onOff
        is SetAccountHidden -> handleSetAccountHidden(event.hidden, event.idx)
        is CopyAccountAddress -> handleCopyAccountAddress(event.idx)
        is ViewPrivKey -> handleViewPrivKey(event.idx)
        is CellButtonAction -> handleCellButtonAction(event.idx)
        is AlertAction -> handleAlertAction(event.idx, event.text)
        is RightBarButtonAction -> handleRightBarButtonAction(event.idx)
        is CTAAction -> handleCTAAction(event.idx)
    }

    private fun handleSetAccountHidden(hidden: Boolean, idx: Int) {
        interactor.setAccountHidden(hidden, idx)
        updateView()
    }

    private fun handleCopyAccountAddress(idx: Int)
        = interactor.pasteToClipboard(interactor.accountAddress(idx))

    private fun handleViewPrivKey(idx: Int) {
        presentingPrivKeyAlert = idx
        view.get()?.presentAlert(privKeyAlertViewModel(idx))
    }

    private fun handlerPrivKeyAlertAction(actionIdx: Int) {
        val accIdx = presentingPrivKeyAlert
        presentingPrivKeyAlert = -1
        if (actionIdx == 2) return;
        val key = interactor.accountPrivKey(accIdx, actionIdx == 1)
        interactor.pasteToClipboard(key)
        view.get()?.presentToast(
            ToastViewModel(
                Localized("mnemonic.toast.copy.privKey"),
                SysName("square.on.square"),
                ToastViewModel.Position.TOP
            )
        )
    }

    private fun handleAddAccount(path: String? = null) {
        interactor.addAccount(path)
        updateView()
        view.get()?.scrollToBottom()
    }

    private fun handleCustomDerivationPath(actionIdx: Int, path: String?) {
        presentingCustomDerivationAlert = false
        if (actionIdx == 1 || path == null) return;
        if (isValidDerivationPath(path)) {
            try {
                interactor.addAccount(path)
                updateView()
                view.get()?.scrollToBottom()
            }
            catch (err: Throwable) {
                println(err)
                presentCustomDerivationPathError(path)
            }
        } else presentCustomDerivationPathError(path)
    }

    private fun handleCellButtonAction(idx: Int) {
        when (idx) {
            0 -> copyAddress()
            1 -> handleViewPrivKey(0)
            2 -> { handleAddAccount(); return; }
            3 -> presentDeleteConfirmation()
            else -> Unit
        }
        updateView()
    }

    private fun handleAlertAction(idx: Int, text: String? = null) = when {
        presentingPrivKeyAlert > -1 -> handlerPrivKeyAlertAction(idx)
        presentingCustomDerivationAlert -> handleCustomDerivationPath(idx, text)
        presentingDeleteConfirmation -> handleDeleteAlertAction(idx)
        else -> Unit
    }


    private fun handleRightBarButtonAction(idx: Int) {
        if (idx == 1) toggleExpertMode()
        else interactor.showHidden = !interactor.showHidden
        updateView()
    }

    private fun handleCTAAction(idx: Int) {
        when (idx) {
            0 -> {
                interactor.update()?.let { context.updateHandler(it) }
                // HACK: to make sure UI had enough time to update for custom
                // transition to work
                CoroutineScope(uiDispatcher).launch {
                    delay(0.15.seconds)
                    wireframe.navigate(Dismiss)
                }
            }
            1 -> {
                presentingCustomDerivationAlert = true
                view.get()?.presentAlert(customDerivationAlertViewModel())
            }
        }
        updateView()
    }

    private fun presentDeleteConfirmation() {
        presentingDeleteConfirmation = true
        view.get()?.presentAlert(deleteAlertViewModel())
    }

    private fun handleDeleteAlertAction(idx: Int) {
        if (idx == 0) return;
        interactor.delete()
        context.deleteHandler()
        dismiss()
    }

    private fun handleUpdate() {
        ctaTapped = true
        if (!isValidForm) return updateView()
        val updatedItem = interactor.update()
            ?: return wireframe.navigate(Alert(errorAlertContext()))
        context.updateHandler(updatedItem)
        dismiss()
    }

    private fun copyAddress() {
        handleCopyAccountAddress(0)
        val address = interactor.accountAddress(0)
        view.get()?.presentToast(
            ToastViewModel(
                Localized("account.action.copy.toast") + "\n" + address,
                SysName("square.on.square"),
                ToastViewModel.Position.TOP
            )
        )
    }

    private fun presentCustomDerivationPathError(path: String?) {
        view.get()?.presentAlert(
            RegularAlertViewModel(
                Localized("Invalid derivation path"),
                (path ?: "")
                        + Localized("mnemonic.alert.customDerivationError.body"),
                listOf(Action("ok", NORMAL)),
                SysName("x.circle"),
            )
        )
    }

    private fun toggleExpertMode() {
        localExpertMode = !localExpertMode
        if (!localExpertMode) return
        CoroutineScope(uiDispatcher).launch {
            delay(0.15.seconds)
            val title = Localized("toast.expertMode")
            view.get()?.presentToast(
                ToastViewModel(title, SysName("brain"), ToastViewModel.Position.TOP)
            )
        }
    }

    private fun dismiss() {
        context.addAccountHandler()
        wireframe.navigate(Dismiss)
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): Screen = Screen(
        Localized("mnemonicConfirmation.title"),
        listOf(
            mnemonicSection(),
            optionsSection(),
        ) + buttonsSections() + accountsSections(),
        listOf(
            BarButton(
                null,
                SysName(if (interactor.showHidden) "eye.slash" else "eye"),
                interactor.hiddenAccountsCount() == 0
            ),
            BarButton(null, SysName("brain"), interactor.globalExpertMode()),
        ),
        if (expertMode())
            listOf(
                ButtonViewModel(Localized("mnemonic.cta.new")),
                ButtonViewModel(Localized("mnemonic.cta.custom"), SECONDARY),
            )
        else listOf(ButtonViewModel(Localized("mnemonic.cta.update"))),
    )

    private fun mnemonicSection(): Section = Section(
        null,
        listOf(Text(interactor.mnemonic())),
        HighlightWords(
            Localized("mnemonic.footer"),
            listOf(
                Localized("mnemonic.footerHighlightWord0"),
                Localized("mnemonic.footerHighlightWord1"),
            )
        ),
    )

    private fun optionsSection(): Section = Section(
        null,
        listOf(
            CellViewModel.TextInput(
                Localized("mnemonic.name.title"),
                interactor.name,
                Localized("mnemonic.name.placeholder"),
            ),
            CellViewModel.Switch(
                Localized("mnemonic.iCould.title"),
                interactor.iCloudSecretStorage,
            )
        ),
        null
    )

    private fun buttonsSections(): List<Section> = listOf(
        ButtonViewModel(Localized("mnemonic.copy.address"), SECONDARY),
        ButtonViewModel(Localized("mnemonic.view.privKey"), SECONDARY),
        ButtonViewModel(Localized("mnemonic.cta.account"), SECONDARY),
        ButtonViewModel(Localized("mnemonic.cta.delete"), DESTRUCTIVE),
    ).map { Section(items = listOf(Button(it))) }

    @OptIn(ExperimentalStdlibApi::class)
    private fun accountsSections(): List<Section>
        = (0..<interactor.accountsCount()).map {
            Section(
                CollectionViewModel.Header.Title(
                    "Account ${interactor.absoluteAccountIdx(it)}",
                    interactor.accountDerivationPath(it)
                ),
                listOf(
                    CellViewModel.KeyValueList(
                        listOf(
                            CellViewModel.KeyValueList.Item(
                                Localized("mnemonic.account.name"),
                                interactor.accountName(it),
                                Localized("mnemonic.account.name.placeholder"),
                            ),
                            CellViewModel.KeyValueList.Item(
                                Localized("mnemonic.copy.address"),
                                Localized("mnemonic.view.privKey"),
                                interactor.accountAddress(it),
                            ),
                        ),
                        mapOf("isHidden" to interactor.accountIsHidden(it))
                    )
                ),
                CollectionViewModel.Footer.Text(interactor.accountAddress(it)),
            )
        }

    private fun customDerivationAlertViewModel(): AlertViewModel
        = AlertViewModel.InputAlertViewModel(
            Localized("mnemonic.alert.customDerivation.title"),
            Localized("mnemonic.alert.customDerivation.body"),
            "",
            "m/44'/60'/0'/0/0",
            listOf(
                Action(Localized("mnemonic.alert.customDerivation.cta"), NORMAL),
                Action(Localized("cancel"), CANCEL),
            ),
            SysName("key.radiowaves.forward")
        )

    private fun privKeyAlertViewModel(accIdx: Int): AlertViewModel
        = RegularAlertViewModel(
            Localized("mnemonic.alert.privKey.title"),
            Localized("mnemonic.alert.privKey.body.priv")
                + "\n${interactor.accountPrivKey(accIdx)}\n\n"
                + Localized("mnemonic.alert.privKey.body.xprv")
                + "\n${interactor.accountPrivKey(accIdx, true)}\n",
            listOf(
                Action(Localized("mnemonic.alert.privKey.btnPriv"), NORMAL),
                Action(Localized("mnemonic.alert.privKey.btnXprv"), NORMAL),
                Action(Localized("cancel"), CANCEL),
            ),
            SysName("key.horizontal")
        )

    private val isValidForm: Boolean get() = passwordErrorMessage == null

    private val passwordErrorMessage: String? get() {
        if (!ctaTapped) return null
        if (interactor.name.isEmpty()) { return Localized("mnemonic.error.invalid.name") }
        return null
    }

    private fun expertMode(): Boolean {
        return interactor.globalExpertMode() || localExpertMode
    }

    private fun authenticateContext(): AuthenticateWireframeContext
        = AuthenticateWireframeContext(
            Localized("authenticate.title.unlock"),
            context.signerStoreItem,
        ) { auth, error ->
            if (auth == null || error != null) {
                dismiss()
                return@AuthenticateWireframeContext
            }
            interactor.setup(context.signerStoreItem, auth.password, auth.salt)
            if (interactor.mnemonic().isEmpty()) dismiss()
            else updateView()
        }

    private fun errorAlertContext(): AlertWireframeContext
        = AlertWireframeContext(
            Localized("mnemonic.update.failed.alert.title"),
            null,
            Localized("mnemonic.update.failed.alert.message"),
            listOf(
                AlertWireframeContext.Action(
                    Localized("ok"),
                    AlertWireframeContext.Action.Type.PRIMARY
                )
            ),
            null,
            350.toDouble()
    )

    private fun deleteAlertViewModel(): AlertViewModel = RegularAlertViewModel(
        Localized("alert.deleteWallet.title"),
        Localized("alert.deleteWallet.message"),
        listOf(
            Action(Localized("cancel"), CANCEL),
            Action(
                Localized("alert.deleteWallet.action.confirm"),
                Action.Kind.DESTRUCTIVE
            ),
        ),
        SysName("exclamationmark.triangle", ImageMedia.Tint.DESTRUCTIVE)
    )
}
