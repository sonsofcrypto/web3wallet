package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.viewModels.SectionFooterViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.SegmentWithTextAndSwitchCellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.SwitchCollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.TextInputCollectionViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized

sealed class MnemonicNewPresenterEvent {
    data class DidChangeName(val name: String): MnemonicNewPresenterEvent()
    data class DidChangeICouldBackup(val onOff: Boolean): MnemonicNewPresenterEvent()
    data class SaltSwitchDidChange(val onOff: Boolean): MnemonicNewPresenterEvent()
    data class DidChangeSalt(val salt: String): MnemonicNewPresenterEvent()
    object SaltLearnMoreAction: MnemonicNewPresenterEvent()
    data class PassTypeDidChange(val idx: Int): MnemonicNewPresenterEvent()
    data class PasswordDidChange(val text: String): MnemonicNewPresenterEvent()
    data class AllowFaceIdDidChange(val onOff: Boolean): MnemonicNewPresenterEvent()
    object DidTapMnemonic: MnemonicNewPresenterEvent()
    object DidSelectCta: MnemonicNewPresenterEvent()
    object DidSelectDismiss: MnemonicNewPresenterEvent()
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
    private var mnemonic = interactor.generateMnemonic()
    private var name = ""
    private var iCloudSecretStorage = false
    private var saltMnemonicOn = false
    private var salt = ""
    private var passwordType: SignerStoreItem.PasswordType = BIO
    private var password = ""
    private var passUnlockWithBio = true
    private var selectedLocation = 0
    private var ctaTapped = false

    override fun present() { updateView() }

    override fun handle(event: MnemonicNewPresenterEvent) {
        when (event) {
            is MnemonicNewPresenterEvent.DidChangeName -> {
                name = event.name
            }
            is MnemonicNewPresenterEvent.DidChangeICouldBackup -> {
                iCloudSecretStorage = event.onOff
            }
            is MnemonicNewPresenterEvent.SaltSwitchDidChange -> {
                saltMnemonicOn = event.onOff
            }
            is MnemonicNewPresenterEvent.DidChangeSalt -> {
                salt = event.salt
            }
            is MnemonicNewPresenterEvent.SaltLearnMoreAction -> {
                wireframe.navigate(MnemonicNewWireframeDestination.LearnMoreSalt)
            }
            is MnemonicNewPresenterEvent.PassTypeDidChange -> {
                passwordType = passwordTypes()[event.idx]
                updateView()
            }
            is MnemonicNewPresenterEvent.PasswordDidChange -> {
                password = event.text
                updateView()
            }
            is MnemonicNewPresenterEvent.AllowFaceIdDidChange -> {
                passUnlockWithBio = event.onOff
            }
            is MnemonicNewPresenterEvent.DidTapMnemonic -> {
                interactor.pasteToClipboard(mnemonic.trim())
            }
            is MnemonicNewPresenterEvent.DidSelectCta -> {
                ctaTapped = true
                if (!isValidForm) return updateView()
                if (passwordType == BIO) {
                    password = interactor.generatePassword()
                }
                try {
                    createDefaultNameIfNeeded()
                    val item = interactor.createKeyStoreItem(keyStoreItemData, password, salt)
                    context.handler(item)
                    wireframe.navigate(MnemonicNewWireframeDestination.Dismiss)
                } catch (e: Throwable) {
                    // TODO: Handle error
                    println("[ERROR] $e")
                }
            }
            is MnemonicNewPresenterEvent.DidSelectDismiss -> {
                wireframe.navigate(MnemonicNewWireframeDestination.Dismiss)
            }
        }
    }

    private val keyStoreItemData: MnemonicNewInteractorData
        get() = MnemonicNewInteractorData(
        mnemonic.trim().split(" "),
        name,
        passUnlockWithBio,
        iCloudSecretStorage,
        saltMnemonicOn,
        passwordType
    )

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): MnemonicNewViewModel {
        val sections = mutableListOf<MnemonicNewViewModel.Section>()
        sections.add(mnemonicSection())
        sections.add(optionsSection())
        return MnemonicNewViewModel(
            sections,
            Localized("mnemonic.cta.new"),
        )
    }

    private fun mnemonicSection(): MnemonicNewViewModel.Section =
        MnemonicNewViewModel.Section(
            listOf(MnemonicNewViewModel.Section.Item.Mnemonic(mnemonic)),
            mnemonicFooterDefault()
        )

    private fun mnemonicFooterDefault(): SectionFooterViewModel = SectionFooterViewModel(
        Localized("mnemonic.footer"),
        listOf(
            Localized("mnemonic.footerHighlightWord0"),
            Localized("mnemonic.footerHighlightWord1"),
        )
    )

    private fun optionsSection(): MnemonicNewViewModel.Section = MnemonicNewViewModel.Section(
        optionSectionsItems(),
        null
    )

    private fun optionSectionsItems(): List<MnemonicNewViewModel.Section.Item> = listOf(
        MnemonicNewViewModel.Section.Item.TextInput(
            TextInputCollectionViewModel(
                Localized("mnemonic.name.title"),
                name,
                Localized("mnemonic.name.placeholder"),
            )
        ),
        MnemonicNewViewModel.Section.Item.Switch(
            SwitchCollectionViewModel(
                Localized("mnemonic.iCould.title"),
                iCloudSecretStorage,
            )
        ),
//        MnemonicNewViewModel.Section.Item.SwitchWithTextInput(
//            SwitchTextInputCollectionViewModel(
//                Localized("mnemonic.salt.title"),
//                saltMnemonicOn,
//                salt,
//                Localized("mnemonic.salt.placeholder"),
//                Localized("mnemonic.salt.description"),
//                listOf(
//                    Localized("mnemonic.salt.descriptionHighlight")
//                ),
//            )
//        ),
        MnemonicNewViewModel.Section.Item.SegmentWithTextAndSwitchInput(
            SegmentWithTextAndSwitchCellViewModel(
                Localized("mnemonic.passType.title"),
                passwordTypes().map { it.name.lowercase() },
                selectedPasswordTypeIdx(),
                password,
                if (passwordType == SignerStoreItem.PasswordType.PIN) SegmentWithTextAndSwitchCellViewModel.KeyboardType.NUMBER_PAD else SegmentWithTextAndSwitchCellViewModel.KeyboardType.DEFAULT,
                Localized("mnemonic.$placeholderType.placeholder"),
                passwordErrorMessage,
                Localized("mnemonic.passType.allowFaceId"),
                passUnlockWithBio,
            )
        )
    )

    private val placeholderType: String get() = if (passwordType == SignerStoreItem.PasswordType.PIN) "pinType" else "passType"

    private fun passwordTypes(): List<SignerStoreItem.PasswordType> =
        SignerStoreItem.PasswordType.values().map { it }

    private fun selectedPasswordTypeIdx(): Int {
        val index = passwordTypes().indexOf(passwordType)
        return if (index == -1) return 2 else index
    }

    private val isValidForm: Boolean get() = passwordErrorMessage == null

    private val passwordErrorMessage: String? get() {
        if (!ctaTapped) return null
        return interactor.validationError(password, passwordType)
    }

    private fun createDefaultNameIfNeeded() {
        if (name.isEmpty()) {
            name = Localized("mnemonic.defaultWalletName")
            if (interactor.keyStoreItemsCount() > 0)
                name = "$name ${interactor.keyStoreItemsCount()}"
        }
    }
}
