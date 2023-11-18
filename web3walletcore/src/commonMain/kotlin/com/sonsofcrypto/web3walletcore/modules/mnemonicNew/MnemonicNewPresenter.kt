package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.PIN
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Style.SECONDARY
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Accessory.COPY
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Label
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.DEFAULT
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.NUMBER_PAD
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.TextInput
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.Text
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Header.Title
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
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
    object AddAccount: MnemonicNewPresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): MnemonicNewPresenterEvent()
    data class CopyAccountAddress(val idx: Int): MnemonicNewPresenterEvent()
//    data class CopyPrivKey(val idx: Int): MnemonicNewPresenterEvent()
    object CreateMnemonic: MnemonicNewPresenterEvent()
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
            is MnemonicNewPresenterEvent.AddAccount -> {
                interactor.addAccount()
                updateView()
            }
            is MnemonicNewPresenterEvent.SetAccountName -> {
                interactor.setAccountName(event.name, event.idx)
            }
            is MnemonicNewPresenterEvent.CopyAccountAddress -> {
                val address = interactor.accountAddress(event.idx)
                interactor.pasteToClipboard(address)
            }
//            is MnemonicNewPresenterEvent.CopyPrivKey -> {
//                interactor.
//            }
            is MnemonicNewPresenterEvent.CreateMnemonic -> {
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
            is MnemonicNewPresenterEvent.Dismiss -> {
                wireframe.navigate(MnemonicNewWireframeDestination.Dismiss)
            }
        }
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): Screen = Screen(
        Localized("mnemonic.title.new"),
        listOf(mnemonicSection(), optionsSection()) + accountsSections(),
        listOf(
            ButtonViewModel(Localized("mnemonic.title.add.account"), SECONDARY),
            ButtonViewModel(Localized("mnemonic.cta.new"))
        )
    )

    private fun mnemonicSection(): Section = Section(
        null,
        listOf(CellViewModel.Text(interactor.mnemonic())),
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
            CellViewModel.Switch(
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
            CellViewModel.SegmentWithTextAndSwitch(
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
    private fun accountsSections(): List<Section> {
        if (interactor.accountsCount() <= 1)
            return emptyList()
        val formatter = Formatters.networkAddress
        return (0..<interactor.accountsCount()).map {
            Section(
                Title("Account $it", interactor.accountDerivationPath(it)),
                listOf(
                    TextInput(
                        Localized("mnemonic.account.name"),
                        interactor.accountName(it),
                        Localized("mnemonic.account.name.placeholder"),
                    ),
                    Label(
                        "Address ${interactor.accountAddress(it)}",
                        COPY,
                    ),
                ),
                null
            )
        }
    }

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
}
