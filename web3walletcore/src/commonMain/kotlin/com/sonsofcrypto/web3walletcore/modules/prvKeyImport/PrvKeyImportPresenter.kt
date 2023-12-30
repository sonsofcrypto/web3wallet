package com.sonsofcrypto.web3walletcore.modules.prvKeyImport

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.PIN
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
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.AlertAction
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.CTAAction
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.CopyAccountAddress
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.CopyPrivKey
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.Dismiss
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.RightBarButtonAction
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetAccountHidden
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetAccountName
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetAllowFaceId
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetICouldBackup
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetKey
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetName
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetPassType
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.SetPassword
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrivKeyImportPresenterEvent.ViewPrivKey
import kotlin.time.Duration.Companion.seconds

sealed class PrivKeyImportPresenterEvent {
    data class SetKey(val text: String): PrivKeyImportPresenterEvent()
    object CopyPrivKey: PrivKeyImportPresenterEvent()
    data class SetName(val name: String): PrivKeyImportPresenterEvent()
    data class SetICouldBackup(val onOff: Boolean): PrivKeyImportPresenterEvent()
    data class SetPassType(val idx: Int): PrivKeyImportPresenterEvent()
    data class SetPassword(val text: String): PrivKeyImportPresenterEvent()
    data class SetAllowFaceId(val onOff: Boolean): PrivKeyImportPresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): PrivKeyImportPresenterEvent()
    data class SetAccountHidden(val hidden: Boolean, val idx: Int): PrivKeyImportPresenterEvent()
    data class CopyAccountAddress(val idx: Int): PrivKeyImportPresenterEvent()
    data class ViewPrivKey(val idx: Int): PrivKeyImportPresenterEvent()
    data class AlertAction(val idx: Int, val text: String?): PrivKeyImportPresenterEvent()
    data class RightBarButtonAction(val idx: Int): PrivKeyImportPresenterEvent()
    data class CTAAction(val idx: Int): PrivKeyImportPresenterEvent()
    object Dismiss: PrivKeyImportPresenterEvent()
}

interface PrivKeyImportPresenter {
    fun present()
    fun handle(event: PrivKeyImportPresenterEvent)
}

class DefaultPrivKeyImportPresenter(
    private val view: WeakRef<PrvKeyImportView>,
    private val wireframe: PrvKeyImportWireframe,
    private val interactor: PrvKeyImportInteractor,
    private val context: PrvKeyImportWireframeContext,
): PrivKeyImportPresenter {
    private var ctaTapped = false
    private var localExpertMode: Boolean = false
    /** -1 alert not presented. Else it is idx of account alert is about */
    private var presentingPrivKeyAlert: Int = -1

    override fun present() { updateView() }

    override fun handle(event: PrivKeyImportPresenterEvent): Unit = when (event) {
        is SetKey -> handleKeyInput(event.text)
        is SetName -> interactor.name = event.name
        is SetICouldBackup -> interactor.iCloudSecretStorage = event.onOff
        is SetPassType -> handleSetPassType(event.idx)
        is SetPassword -> handleSetPassword(event.text)
        is SetAllowFaceId -> interactor.passUnlockWithBio = event.onOff
        is CopyPrivKey -> interactor.pasteToClipboard(interactor.prvKey())
        is SetAccountName -> interactor.setAccountName(event.name, event.idx)
        is SetAccountHidden -> handleSetAccountHidden(event.hidden, event.idx)
        is CopyAccountAddress -> handleCopyAccountAddress(event.idx)
        is ViewPrivKey -> handleViewPrivKey(event.idx)
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
                + "\n${interactor.accountPrivKey(accIdx)}\n\n"
                + Localized("mnemonic.alert.prvKey.body.xprv")
                + "\n${interactor.accountPrivKey(accIdx, true)}\n",
            listOf(
                Action(Localized("mnemonic.alert.prvKey.btnPriv"), NORMAL),
                Action(Localized("mnemonic.alert.prvKey.btnXprv"), NORMAL),
                Action(Localized("cancel"), Action.Kind.CANCEL),
            ),
            SysName("key.horizontal")
        )

    private fun handlerPrivKeyAlertAction(actionIdx: Int) {
        val accIdx = presentingPrivKeyAlert
        presentingPrivKeyAlert = -1
        if (actionIdx == 2) return;
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
                context.handler(interactor.createPrvKeySigner())
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
        wireframe.navigate(PrvKeyImportWireframeDestination.Dismiss)

    private fun updateView(updateMnemonic: Boolean = false) =
        view.get()?.update(viewModel(), inputViewModel())

    private fun presentToast(viewModel: ToastViewModel) =
        view.get()?.presentToast(viewModel)

    private fun presentAlert(viewModel: AlertViewModel) =
        view.get()?.presentAlert(viewModel)

    private fun inputViewModel(): PrvKeyInputViewModel =
        PrvKeyInputViewModel(
            interactor.isPrvKeyValid(),
            interactor.prvKeyError(),
        )

    private fun viewModel(): Screen = Screen(
        Localized("prvKeyImport.title.import"),
        listOf(prvKeySection()) + (
            if (!interactor.isPrvKeyValid()) emptyList()
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
        footer = prvKeyFooter(interactor.prvKeyError()),
    )

    private fun prvKeyFooter(error: PrvKeyImportError? = null): Footer {
        if (error == null)
            return HighlightWords(
                Localized("prvKeyImport.footer"),
                listOf(
                    Localized("prvKeyImport.footerHighlightWord0"),
                    Localized("prvKeyImport.footerHighlightWord1"),
                )
            )
        return when (error) {
            PrvKeyImportError.INVALID_WORD_COUNT -> HighlightWords(
                Localized("mnemonic.error.invalid.wordCount"),
                listOf(Localized("mnemonic.error.invalid.wordCount.highlight"))
            )
            PrvKeyImportError.OTHER -> HighlightWords(
                Localized("mnemonic.error.invalid"),
                listOf(Localized("mnemonic.error.invalid"))
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
        return interactor.isPrvKeyValid() && passwordErrorMessage == null
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
