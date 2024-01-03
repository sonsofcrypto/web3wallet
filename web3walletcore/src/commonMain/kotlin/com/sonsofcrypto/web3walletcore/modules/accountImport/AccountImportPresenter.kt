package com.sonsofcrypto.web3walletcore.modules.accountImport

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.PIN
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.Type.PRVKEY
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.execDelayed
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.NORMAL
import com.sonsofcrypto.web3walletcore.common.viewModels.BarButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.DEFAULT
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.NUMBER_PAD
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Switch
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel.Position.TOP
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.AlertAction
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.CTAAction
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.CopyAccountAddress
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.Dismiss
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.RightBarButtonAction
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetAccountHidden
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetAccountName
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetAllowFaceId
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetICouldBackup
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetInput
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetName
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetPassType
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.SetPassword
import com.sonsofcrypto.web3walletcore.modules.accountImport.AccountImportPresenterEvent.ViewPrvKey
import kotlin.time.Duration.Companion.seconds

sealed class AccountImportPresenterEvent {
    data class SetInput(val text: String): AccountImportPresenterEvent()
    data class SetName(val name: String): AccountImportPresenterEvent()
    data class SetICouldBackup(val onOff: Boolean): AccountImportPresenterEvent()
    data class SetPassType(val idx: Int): AccountImportPresenterEvent()
    data class SetPassword(val text: String): AccountImportPresenterEvent()
    data class SetAllowFaceId(val onOff: Boolean): AccountImportPresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): AccountImportPresenterEvent()
    data class SetAccountHidden(val hidden: Boolean, val idx: Int): AccountImportPresenterEvent()
    data class CopyAccountAddress(val idx: Int): AccountImportPresenterEvent()
    data class ViewPrvKey(val idx: Int): AccountImportPresenterEvent()
    data class AlertAction(val idx: Int, val text: String?): AccountImportPresenterEvent()
    data class RightBarButtonAction(val idx: Int): AccountImportPresenterEvent()
    data class CTAAction(val idx: Int): AccountImportPresenterEvent()
    object Dismiss: AccountImportPresenterEvent()
}

interface AccountImportPresenter {
    fun present()
    fun handle(event: AccountImportPresenterEvent)
}

class DefaultAccountImportPresenter(
    private val view: WeakRef<AccountImportView>,
    private val wireframe: AccountImportWireframe,
    private val interactor: AccountImportInteractor,
    private val context: AccountImportWireframeContext,
): AccountImportPresenter {
    private var ctaTapped = false
    private var localExpertMode: Boolean = false
    /** -1 alert not presented. Else it is idx of account alert is about */
    private var presentingPrivKeyAlert: Int = -1
    private val isPrvKeyMode: Boolean
        get() { return context.signerType == PRVKEY }

    override fun present() {
        interactor.signerType = context.signerType
        updateView()
    }

    override fun handle(event: AccountImportPresenterEvent): Unit = when (event) {
        is SetInput -> handleKeyInput(event.text)
        is SetName -> interactor.name = event.name
        is SetICouldBackup -> interactor.iCloudSecretStorage = event.onOff
        is SetPassType -> handleSetPassType(event.idx)
        is SetPassword -> handleSetPassword(event.text)
        is SetAllowFaceId -> interactor.passUnlockWithBio = event.onOff
        is SetAccountName -> interactor.setAccountName(event.name, event.idx)
        is SetAccountHidden -> handleSetAccountHidden(event.hidden, event.idx)
        is CopyAccountAddress -> handleCopyAccountAddress(event.idx)
        is ViewPrvKey -> handleViewPrivKey(event.idx)
        is AlertAction -> handleAlertAction(event.idx, event.text)
        is RightBarButtonAction -> handleRightBarButtonAction(event.idx)
        is CTAAction -> handleCTAAction(event.idx)
        is Dismiss -> navigateToDismiss()
    }

    private fun handleKeyInput(keyText: String) {
        interactor.keyInput = keyText
        updateView()
    }

    private fun handleSetPassType(typeIdx: Int) {
        interactor.passwordType = passwordTypes()[typeIdx]
        updateView()
    }

    private fun handleSetPassword(pass: String) {
        interactor.password = pass
        updateView()
    }

    private fun handleSetAccountHidden(hidden: Boolean, idx: Int) {
        interactor.setAccountHidden(hidden, idx)
        updateView()
    }

    private fun handleCopyAccountAddress(idx: Int)
        = interactor.pasteToClipboard(interactor.accountAddress(idx))

    private fun handleViewPrivKey(idx: Int) {
        presentingPrivKeyAlert = idx
        view.get()?.presentAlert(prvKeyAlertViewModel(idx))
    }

    private fun prvKeyAlertViewModel(accIdx: Int): AlertViewModel
        = AlertViewModel.RegularAlertViewModel(
            Localized("mnemonic.alert.prvKey.title"),
            Localized("mnemonic.alert.prvKey.body.prv")
                + "\n${interactor.accountPrivKey(accIdx)}\n\n",
            listOf(
                Action(Localized("mnemonic.alert.prvKey.btnPriv"), NORMAL),
                Action(Localized("cancel"), Action.Kind.CANCEL),
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
        presentToast(ToastViewModel((title), SysName("square.on.square"), TOP))
    }

    private fun handleAlertAction(idx: Int, text: String?) {
        if (presentingPrivKeyAlert > -1) {
            handlerPrivKeyAlertAction(idx)
        }
    }

    private fun handleRightBarButtonAction(idx: Int) {
        if (idx == 1) toggleExpertMode()
        else interactor.showHidden = !interactor.showHidden
        updateView()
    }

    private fun toggleExpertMode() {
        localExpertMode = !localExpertMode
        if (!localExpertMode) return
        execDelayed(0.15.seconds) {
            val title = Localized("toast.expertMode")
            presentToast(ToastViewModel(title, SysName("brain"), TOP))
        }
    }

    private fun handleCTAAction(idx: Int) {
        if (!expertMode()) {
            handleCreateWallet()
            return
        }
        when (idx) {
            0 -> handleCreateWallet()
        }
    }

    private fun handleCreateWallet() {
        ctaTapped = true
        if (!isValidForm) { updateView(); return }
        if (interactor.passwordType == BIO) {
            interactor.password = interactor.generatePassword()
        }
        try {
            presentAlert(generatingAccountsViewModel())
            // NOTE: Hack to dispatch following on next run loops so that alert
            // appears on straight await
            execDelayed(0.05.seconds) {
                interactor.generateDefaultNameIfNeeded()
                context.handler(interactor.createSigner())
                navigateToDismiss()
            }
        } catch (e: Throwable) {
            // TODO: Handle error
            println("[PrivKeyImportPresenter.handleCreateWallet] $e")
        }
    }

    private fun generatingAccountsViewModel(): AlertViewModel =
        AlertViewModel.LoadingImageAlertViewModel(
            Localized("mnemonic.alert.updating.title"),
            "",
            listOf(),
            ImageMedia.Name("overscroll_pepe_analyst")
        )

    private fun navigateToDismiss() =
        wireframe.navigate(AccountImportWireframeDestination.Dismiss)

    private fun updateView(updateMnemonic: Boolean = false) =
        view.get()?.update(viewModel(), inputViewModel())

    private fun presentToast(viewModel: ToastViewModel) =
        view.get()?.presentToast(viewModel)

    private fun presentAlert(viewModel: AlertViewModel) =
        view.get()?.presentAlert(viewModel)

    private fun inputViewModel(): AccountImportInputViewModel =
        AccountImportInputViewModel(
            interactor.keyInput ?: "",
            interactor.isValid(),
            interactor.keyError(),
        )

    private fun viewModel(): Screen = Screen(
        Localized(
            if (isPrvKeyMode) "accountImport.prv.title"
            else "accountImport.address.title"
        ),
        listOf(prvKeySection()) + (
            if (!interactor.isValid()) emptyList()
            else listOf(optionsSection()) + accountsSections()
        ),
        listOf(
            BarButtonViewModel(
                null,
                SysName(if (interactor.showHidden) "eye.slash" else "eye"),
                interactor.hiddenAccountsCount() == 0
            ),
            BarButtonViewModel(null, SysName("brain"), interactor.globalExpertMode()),
        ),
        listOf(ButtonViewModel(Localized("mnemonic.cta.import")))
    )

    private fun prvKeySection(): Section = Section(
        items = listOf(CellViewModel.Text(interactor.keyInput)),
        footer = prvKeyFooter(interactor.keyError()),
    )

    private fun prvKeyFooter(error: AccountImportError? = null): Footer {
        if (error == null)
            return HighlightWords(
                Localized(
                    if (isPrvKeyMode) "accountImport.prv.footer"
                    else "accountImport.address.footer"
                ),
                listOf(
                    Localized("prvKeyImport.footerHighlightWord0"),
                    Localized("prvKeyImport.footerHighlightWord1"),
                )
            )
        return when (error) {
            AccountImportError.NOT_HEX_DIGIT -> HighlightWords(
                Localized("accountImport.error.hexDigit"),
            )
            AccountImportError.INVALID_PRV_KEY -> HighlightWords(
                Localized("accountImport.error.invalid"),
            )
            AccountImportError.INVALID_ADDRESS -> HighlightWords(
                Localized("accountImport.error.address")
            )
        }
    }

    private fun optionsSection(): Section = Section(
        items = listOf(
            CellViewModel.TextInput(
                Localized("mnemonic.name.title"),
                interactor.name,
                Localized("mnemonic.name.placeholder"),
            ),
            Switch(
                Localized("mnemonic.iCould.title"),
                interactor.iCloudSecretStorage,
            ),
            SegmentWithTextAndSwitch(
                Localized("mnemonic.passType.title"),
                passwordTypes().map { it.name.lowercase() },
                selectedPasswordTypeIdx(),
                interactor.password,
                if (interactor.passwordType == PIN) NUMBER_PAD else DEFAULT,
                Localized("mnemonic.$placeholderType.placeholder"),
                passwordErrorMessage,
                Localized("mnemonic.passType.allowFaceId"),
                interactor.passUnlockWithBio,
            ),
        ),
    )

    private fun accountsSections(): List<Section>
        = if (!expertMode() && interactor.accountsCount() <= 1)
            emptyList()
        else (0..<interactor.accountsCount()).map {
            Section(
                CollectionViewModel.Header.Title(
                    Localized(
                        if (isPrvKeyMode) "accountImport.prv.accountSectionTitle"
                        else "accountImport.address.accountSectionTitle"
                    ),
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
                        mapOf(
                            "isHidden" to interactor.accountIsHidden(it),
                            "hideTrailingBtn" to !isPrvKeyMode
                        )
                    )
                ),
                Footer.Text(interactor.accountAddress(it)),
            )
        }

    private val placeholderType: String get()
        = if (interactor.passwordType == PIN) "pinType" else "passType"

    private fun passwordTypes(): List<SignerStoreItem.PasswordType> =
        SignerStoreItem.PasswordType.values().map { it }

    private fun selectedPasswordTypeIdx(): Int {
        val index = passwordTypes().indexOf(interactor.passwordType)
        return if (index == -1) return 2 else index
    }

    private val isValidForm: Boolean get() {
        return interactor.isValid() && passwordErrorMessage == null
    }

    private val passwordErrorMessage: String? get() {
        if (!ctaTapped) return null
        return interactor.passError(
            interactor.password,
            interactor.passwordType
        )
    }

    private fun expertMode(): Boolean {
        return interactor.globalExpertMode() || localExpertMode
    }
}
