package com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.execDelayed
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.CANCEL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.NORMAL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.RegularAlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.BarButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.DESTRUCTIVE
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.SECONDARY
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Text
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel.Position.TOP
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateData
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.AlertAction
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.CTAAction
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.CopyAccountAddress
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.CopyKey
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.RightBarButtonAction
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.SetAccountHidden
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.SetAccountName
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.SetICouldBackup
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdatePresenterEvent.ViewPrivKey
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdateWireframeDestination.Authenticate
import com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate.PrvKeyUpdateWireframeDestination.Dismiss
import kotlin.time.Duration.Companion.seconds

sealed class PrvKeyUpdatePresenterEvent {
    object CopyKey: PrvKeyUpdatePresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): PrvKeyUpdatePresenterEvent()
    data class SetICouldBackup(val onOff: Boolean): PrvKeyUpdatePresenterEvent()
    data class SetAccountHidden(val hidden: Boolean, val idx: Int): PrvKeyUpdatePresenterEvent()
    data class CopyAccountAddress(val idx: Int): PrvKeyUpdatePresenterEvent()
    data class ViewPrivKey(val idx: Int): PrvKeyUpdatePresenterEvent()
    data class AlertAction(val idx: Int, val text: String?): PrvKeyUpdatePresenterEvent()
    data class RightBarButtonAction(val idx: Int): PrvKeyUpdatePresenterEvent()
    data class CTAAction(val idx: Int): PrvKeyUpdatePresenterEvent()
    object Dismiss: PrvKeyUpdatePresenterEvent()
}

interface PrvKeyUpdatePresenter {
    fun present()
    fun handle(event: PrvKeyUpdatePresenterEvent)
}

class DefaultPrvKeyUpdatePresenter(
    private val view: WeakRef<PrvKeyUpdateView>,
    private val wireframe: PrvKeyUpdateWireframe,
    private val interactor: PrvKeyUpdateInteractor,
    private val context: PrvKeyUpdateWireframeContext,
): PrvKeyUpdatePresenter {
    private var authenticated: Boolean = false
    private var localExpertMode: Boolean = false
    /** -1 alert not presented. Else it is idx of account alert is about */
    private var presentingPrivKeyAlert: Int = -1
    private var presentingDeleteConfirmation: Boolean = false

    override fun present() {
        updateView()
        if (!authenticated) {
            val cxt = authContext(context.signerStoreItem, false)
            wireframe.navigate(Authenticate(cxt))
            authenticated = true
        }
    }

    private fun authContext(
        item: SignerStoreItem,
        authForPrivKey: Boolean
    ): AuthenticateWireframeContext {
        val title = Localized("authenticate.title.unlock")
        return AuthenticateWireframeContext(title, item) { auth, err ->
            if (authForPrivKey) handleAuthPrivKey(item, auth, err)
            else handleAuthUnlock(item, auth, err)
        }
    }

    private fun handleAuthUnlock(
        item: SignerStoreItem,
        auth: AuthenticateData?,
        err: Error?
    ) {
        if (auth == null || err != null) { dismiss(); return }
        interactor.setup(item, auth.password, auth.salt)
        // TODO: Try catch show error
        if (interactor.prvKey().isEmpty()) dismiss()
        else updateView()
    }

    private fun handleAuthPrivKey(
        item: SignerStoreItem,
        auth: AuthenticateData?,
        err: Error?
    ) {
        if (auth == null || err != null) return
        val idx = interactor.idxForAccount(item.uuid)
        presentingPrivKeyAlert = idx
        presentAlert(privKeyAlertViewModel(idx, auth.password, auth.salt))
    }

    override fun handle(event: PrvKeyUpdatePresenterEvent) =  when (event) {
        is CopyKey -> interactor.pasteToClipboard(interactor.prvKey())
        is SetAccountName -> interactor.setAccountName(event.name, event.idx)
        is SetICouldBackup -> interactor.iCloudSecretStorage = event.onOff
        is SetAccountHidden -> handleSetAccountHidden(event.hidden, event.idx)
        is CopyAccountAddress -> handleCopyAccountAddress(event.idx)
        is ViewPrivKey -> handleViewPrivKey(event.idx)
        is AlertAction -> handleAlertAction(event.idx, event.text)
        is RightBarButtonAction -> handleRightBarButtonAction(event.idx)
        is CTAAction -> handleCTAAction(event.idx)
        is PrvKeyUpdatePresenterEvent.Dismiss -> dismiss()
    }

    private fun handleSetAccountHidden(hidden: Boolean, idx: Int) {
        interactor.setAccountHidden(hidden, idx)
        updateView()
    }

    private fun handleCopyAccountAddress(idx: Int)
        = interactor.pasteToClipboard(interactor.accountAddress(idx))

    private fun handleViewPrivKey(idx: Int) {
        if (interactor.isPrimaryAccount(idx)) {
            presentingPrivKeyAlert = idx
            presentAlert(privKeyAlertViewModel(idx))
        } else {
            val cxt = authContext(interactor.signer(idx), true)
            wireframe.navigate(Authenticate(cxt))
        }
    }

    private fun privKeyAlertViewModel(
        accIdx: Int,
        pass: String? = null,
        salt: String? = null
    ): AlertViewModel = RegularAlertViewModel(
        Localized("mnemonic.alert.prvKey.title"),
        Localized("mnemonic.alert.prvKey.body.prv")
            + "\n${interactor.accountPrivKey(accIdx, false, pass, salt)}\n\n",
        listOf(
            Action(Localized("mnemonic.alert.prvKey.btnPriv"), NORMAL),
            Action(Localized("cancel"), CANCEL),
        ),
        SysName("key.horizontal")
    )

    private fun handlerPrivKeyAlertAction(actionIdx: Int) {
        val accIdx = presentingPrivKeyAlert
        presentingPrivKeyAlert = -1
        if (actionIdx == 1) return;
        val key = interactor.accountPrivKey(accIdx, actionIdx == 1)
        val title = Localized("mnemonic.toast.copy.prvKey")
        interactor.pasteToClipboard(key)
        presentToast(ToastViewModel(title, SysName("square.on.square"), TOP))
    }

    private fun handleCopyAddress(toast: Boolean = false) {
        val address = interactor.accountAddress(0)
        interactor.pasteToClipboard(address)
        if (!toast) return;
        val title = Localized("account.action.copy.toast") + "\n" + address
        presentToast(ToastViewModel(title, SysName("square.on.square"), TOP))
    }

    private fun presentDeleteConfirmation() {
        presentingDeleteConfirmation = true
        val alertViewModel = RegularAlertViewModel(
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
        presentAlert(alertViewModel)
    }


    private fun handleDeleteAlertAction(idx: Int) {
        presentingDeleteConfirmation = false
        if (idx == 0) return;
        interactor.delete()
        context.deleteHandler()
        dismiss()
    }

    private fun handleAlertAction(idx: Int, text: String? = null) = when {
        presentingPrivKeyAlert > -1 -> handlerPrivKeyAlertAction(idx)
        presentingDeleteConfirmation -> handleDeleteAlertAction(idx)
        else -> Unit
    }

    private fun handleRightBarButtonAction(idx: Int) {
        if (idx == 1) toggleExpertMode()
        else interactor.showHidden = !interactor.showHidden
        updateView()
    }

    private fun toggleExpertMode() {
        localExpertMode = !localExpertMode
        if (localExpertMode) execDelayed(0.15.seconds) {
            val tlt = Localized("toast.expertMode")
            presentToast(ToastViewModel(tlt, SysName("brain"), TOP))
        }
    }

    private fun handleCTAAction(idx: Int) {
        when (idx) {
            0 -> handleCopyAddress(true)
            1 -> presentDeleteConfirmation()
            2 -> handleUpdate()
        }
        updateView()
    }

    private fun handleUpdate() {
        if (interactor.name.isEmpty()) interactor.name = "No name wallet"
        interactor.update()?.let { context.updateHandler(it) }
        // HACK: to make sure UI had enough time to update for custom transition
        execDelayed(0.1.seconds) { wireframe.navigate(Dismiss) }
    }

    private fun dismiss() {
        wireframe.navigate(Dismiss)
    }

    private fun updateView() =
        view.get()?.update(viewModel())

    private fun presentToast(viewModel: ToastViewModel) =
        view.get()?.presentToast(viewModel)

    private fun presentAlert(viewModel: AlertViewModel) =
        view.get()?.presentAlert(viewModel)

    private fun viewModel(): Screen = Screen(
        Localized("mnemonicConfirmation.title"),
        listOf(
            keySection(),
            optionsSection(),
        ) + accountsSections(),
        listOf(
            BarButtonViewModel(
                null,
                SysName(if (interactor.showHidden) "eye.slash" else "eye"),
                interactor.hiddenAccountsCount() == 0
            ),
            BarButtonViewModel(
                null,
                SysName("brain"),
                interactor.globalExpertMode()
            ),
        ),
        listOf(
            ButtonViewModel(Localized("copyAddress"), SECONDARY),
            ButtonViewModel(Localized("mnemonic.cta.delete"), DESTRUCTIVE),
            ButtonViewModel(Localized("mnemonic.cta.update")),
        )
    )

    private fun keySection(): Section = Section(
        null,
        listOf(Text(interactor.prvKey())),
        HighlightWords(
            Localized("prvKeyImport.update.footer"),
            listOf(
                Localized("prvKeyImport.footerHighlightWord0"),
                Localized("prvKeyImport.footerHighlightWord1"),
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
                                Localized("copyAddress"),
                                Localized("mnemonic.view.prvKey"),
                                interactor.accountAddress(it),
                            ),
                        ),
                        mapOf("isHidden" to interactor.accountIsHidden(it))
                    )
                ),
                CollectionViewModel.Footer.Text(interactor.accountAddress(it)),
            )
        }

    private fun expertMode(): Boolean {
        return interactor.globalExpertMode() || localExpertMode
    }
}
