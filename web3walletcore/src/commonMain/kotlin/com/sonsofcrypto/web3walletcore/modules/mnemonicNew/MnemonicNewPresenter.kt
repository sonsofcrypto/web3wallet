package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.PIN
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.CANCEL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.Action.Kind.NORMAL
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel.RegularAlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.SECONDARY
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.*
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.KeyValueList.Item
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.DEFAULT
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.NUMBER_PAD
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.BarButton
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Header.Title
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.extensions.Localized

sealed class MnemonicNewPresenterEvent {
    object CopyMnemonic: MnemonicNewPresenterEvent()
    data class SetName(val name: String): MnemonicNewPresenterEvent()
    data class SetICouldBackup(val onOff: Boolean): MnemonicNewPresenterEvent()
    data class SaltSwitch(val onOff: Boolean): MnemonicNewPresenterEvent()
    data class SetSalt(val salt: String): MnemonicNewPresenterEvent()
    object SaltLearnMore: MnemonicNewPresenterEvent()
    data class SetPassType(val idx: Int): MnemonicNewPresenterEvent()
    data class SetPassword(val text: String): MnemonicNewPresenterEvent()
    data class SetAllowFaceId(val onOff: Boolean): MnemonicNewPresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): MnemonicNewPresenterEvent()
    data class SetAccountHidden(val hidden: Boolean, val idx: Int): MnemonicNewPresenterEvent()
    data class CopyAccountAddress(val idx: Int): MnemonicNewPresenterEvent()
    data class ViewPrivKey(val idx: Int): MnemonicNewPresenterEvent()
    data class RightBarButtonAction(val idx: Int): MnemonicNewPresenterEvent()
    data class AlertAction(val idx: Int): MnemonicNewPresenterEvent()
    data class CTAAction(val idx: Int): MnemonicNewPresenterEvent()
    object Dismiss: MnemonicNewPresenterEvent()
}

interface MnemonicNewPresenter {
    fun present()
    fun handle(event: MnemonicNewPresenterEvent)
}

class DefaultMnemonicNewPresenter(
    private val view: WeakRef<MnemonicNewView>,
    private val wireframe: MnemonicNewWireframe,
    private val interactor: MnemonicNewInteractor,
    private val context: MnemonicNewWireframeContext,
): MnemonicNewPresenter {
    private var ctaTapped = false
    private var localExpertMode: Boolean = false
    /** -1 alert not presented. Else it is idx of account alert is about */
    private var presentingPrivKeyAlert: Int = -1
    private var presentingCustomDerivationAlert: Boolean = false

    override fun present() { updateView() }

    override fun handle(event: MnemonicNewPresenterEvent) {
        when (event) {
            is MnemonicNewPresenterEvent.SetName -> {
                interactor.name = event.name
            }
            is MnemonicNewPresenterEvent.SetICouldBackup -> {
                interactor.iCloudSecretStorage = event.onOff
            }
            is MnemonicNewPresenterEvent.SaltSwitch -> {
                interactor.saltMnemonicOn = event.onOff
            }
            is MnemonicNewPresenterEvent.SetSalt -> {
                interactor.salt = event.salt
            }
            is MnemonicNewPresenterEvent.SaltLearnMore -> {
                wireframe.navigate(MnemonicNewWireframeDestination.LearnMoreSalt)
            }
            is MnemonicNewPresenterEvent.SetPassType -> {
                interactor.passwordType = passwordTypes()[event.idx]
                updateView()
            }
            is MnemonicNewPresenterEvent.SetPassword -> {
                interactor.password = event.text
                updateView()
            }
            is MnemonicNewPresenterEvent.SetAllowFaceId -> {
                interactor.passUnlockWithBio = event.onOff
            }
            is MnemonicNewPresenterEvent.CopyMnemonic -> {
                interactor.pasteToClipboard(interactor.mnemonic().trim())
            }
            is MnemonicNewPresenterEvent.SetAccountName -> {
                interactor.setAccountName(event.name, event.idx)
            }
            is MnemonicNewPresenterEvent.SetAccountHidden -> {
                interactor.setAccountHidden(event.hidden, event.idx)
                updateView()
            }
            is MnemonicNewPresenterEvent.CopyAccountAddress -> {
                val address = interactor.accountAddress(event.idx)
                interactor.pasteToClipboard(address)
            }
            is MnemonicNewPresenterEvent.ViewPrivKey -> {
                presentingPrivKeyAlert = event.idx
                view.get()?.presentAlert(privKeyAlertViewModel(event.idx))
            }
            is MnemonicNewPresenterEvent.RightBarButtonAction -> {
                if (event.idx == 1) localExpertMode = !localExpertMode
                else interactor.showHidden = !interactor.showHidden
                updateView()
            }
            is MnemonicNewPresenterEvent.AlertAction -> {
                if (presentingPrivKeyAlert > -1) {
                    handlerPrivKeyAlertAction(event.idx)
                }
                if (presentingCustomDerivationAlert) {

                    presentingCustomDerivationAlert = false
                }
            }
            is MnemonicNewPresenterEvent.CTAAction -> {
                if (!expertMode()) {
                    createWallet()
                    return
                }
                when (event.idx) {
                    0 -> interactor.addAccount()
                    1 -> createWallet()
                    2 -> {
                        presentingCustomDerivationAlert = true
                        view.get()?.presentAlert(customDerivationAlertViewModel())
                    }
                }
                updateView()
            }
            is MnemonicNewPresenterEvent.Dismiss -> {
                wireframe.navigate(MnemonicNewWireframeDestination.Dismiss)
            }
        }
    }

    private fun createWallet() {
        ctaTapped = true
        if (!isValidForm) return updateView()
        if (interactor.passwordType == BIO) {
            interactor.password = interactor.generatePassword()
        }
        try {
            interactor.generateDefaultNameIfNeeded()
            val item = interactor.createMnemonicSigner()
            context.handler(item)
            wireframe.navigate(MnemonicNewWireframeDestination.Dismiss)
        } catch (e: Throwable) {
            // TODO: Handle error
            println("[ERROR] $e")
        }
    }

    private fun handlerPrivKeyAlertAction(actionIdx: Int) {
        if (actionIdx == 2) return;
        val accIdx = presentingPrivKeyAlert
        val key = interactor.accountPrivKey(accIdx, actionIdx == 1)
        interactor.pasteToClipboard(key)
        // Toast alert
        presentingPrivKeyAlert = -1
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): Screen = Screen(
        Localized("mnemonic.title.new"),
        listOf(mnemonicSection(), optionsSection()) + accountsSections(),
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
                ButtonViewModel(Localized("mnemonic.cta.account"), SECONDARY),
                ButtonViewModel(Localized("mnemonic.cta.new")),
                ButtonViewModel(Localized("mnemonic.cta.custom"), SECONDARY),
            )
        else listOf(ButtonViewModel(Localized("mnemonic.cta.new")))
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
            TextInput(
                Localized("mnemonic.name.title"),
                interactor.name,
                Localized("mnemonic.name.placeholder"),
            ),
            Switch(
                Localized("mnemonic.iCould.title"),
                interactor.iCloudSecretStorage,
            ),
//          CellViewModel.SwitchWithTextInput(
//              Localized("mnemonic.salt.title"),
//              saltMnemonicOn,
//              salt,
//              Localized("mnemonic.salt.placeholder"),
//              Localized("mnemonic.salt.description"),
//              listOf(Localized("mnemonic.salt.descriptionHighlight")),
//          ),
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
        null
    )

    @OptIn(ExperimentalStdlibApi::class)
    private fun accountsSections(): List<Section>
        = if (interactor.accountsCount() <= 1)
            emptyList()
        else (0..<interactor.accountsCount()).map {
            Section(
                Title(
                    "Account ${interactor.absoluteAccountIdx(it)}",
                    interactor.accountDerivationPath(it)
                ),
                listOf(
                    KeyValueList(
                         listOf(
                             Item(
                                 Localized("mnemonic.account.name"),
                                 interactor.accountName(it),
                                 Localized("mnemonic.account.name.placeholder"),
                             ),
                             Item(
                                 Localized("mnemonic.copy.address"),
                                 Localized("mnemonic.view.privKey"),
                                 interactor.accountAddress(it),
                             ),
                         ),
                        mapOf("isHidden" to interactor.accountIsHidden(it))
                    )
                ),
                Footer.Text(interactor.accountAddress(it)),
            )
        }

    private fun customDerivationAlertViewModel(): AlertViewModel {
        TODO("Implement")
    }

    private fun privKeyAlertViewModel(accIdx: Int): AlertViewModel
        = RegularAlertViewModel(
            Localized("mnemonic.privKey.alert.title"),
            Localized("mnemonic.privKey.alert.body.priv")
                + "\n${interactor.accountPrivKey(accIdx)}\n\n"
                + Localized("mnemonic.privKey.alert.body.xprv")
                + "\n${interactor.accountPrivKey(accIdx, true)}\n",
            listOf(
                Action(Localized("mnemonic.privKey.alert.btnPriv"), NORMAL),
                Action(Localized("mnemonic.privKey.alert.btnXprv"), NORMAL),
                Action(Localized("cancel"), CANCEL),
            ),
            SysName("key.horizontal")
        )

    private val placeholderType: String get()
        = if (interactor.passwordType == PIN) "pinType" else "passType"

    private fun passwordTypes(): List<SignerStoreItem.PasswordType> =
        SignerStoreItem.PasswordType.values().map { it }

    private fun selectedPasswordTypeIdx(): Int {
        val index = passwordTypes().indexOf(interactor.passwordType)
        return if (index == -1) return 2 else index
    }

    private val isValidForm: Boolean get() = passwordErrorMessage == null

    private val passwordErrorMessage: String? get() {
        if (!ctaTapped) return null
        return interactor.validationError(
            interactor.password,
            interactor.passwordType
        )
    }

    private fun expertMode(): Boolean {
        return interactor.globalExpertMode() || localExpertMode
    }
}
