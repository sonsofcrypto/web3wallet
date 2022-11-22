package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem.PasswordType.PIN
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.mnemonic.MnemonicPresenterCommon
import com.sonsofcrypto.web3walletcore.common.viewModels.*
import com.sonsofcrypto.web3walletcore.common.viewModels.SegmentWithTextAndSwitchCellViewModel.KeyboardType.DEFAULT
import com.sonsofcrypto.web3walletcore.common.viewModels.SegmentWithTextAndSwitchCellViewModel.KeyboardType.NUMBER_PAD
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportViewModel.Section.Mnemonic.WordInfo
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicServiceError

sealed class MnemonicImportPresenterEvent {
    data class MnemonicChanged(
        val to: String, val selectedLocation: Int
    ): MnemonicImportPresenterEvent()
    data class DidChangeName(val name: String): MnemonicImportPresenterEvent()
    data class DidChangeICouldBackup(val onOff: Boolean): MnemonicImportPresenterEvent()
    data class SaltSwitchDidChange(val onOff: Boolean): MnemonicImportPresenterEvent()
    data class DidChangeSalt(val salt: String): MnemonicImportPresenterEvent()
    object SaltLearnMoreAction: MnemonicImportPresenterEvent()
    data class PassTypeDidChange(val idx: Int): MnemonicImportPresenterEvent()
    data class PasswordDidChange(val text: String): MnemonicImportPresenterEvent()
    data class AllowFaceIdDidChange(val onOff: Boolean): MnemonicImportPresenterEvent()
    object DidTapMnemonic: MnemonicImportPresenterEvent()
    object DidSelectCta: MnemonicImportPresenterEvent()
    object DidSelectDismiss: MnemonicImportPresenterEvent()
}

interface MnemonicImportPresenter {
    fun present()
    fun handle(event: MnemonicImportPresenterEvent)
}

class DefaultMnemonicImportPresenter(
    private val view: WeakRef<MnemonicImportView>,
    private val wireframe: MnemonicImportWireframe,
    private val interactor: MnemonicImportInteractor,
    private val context: MnemonicImportWireframeContext,
): MnemonicImportPresenter {
    private val common = MnemonicPresenterCommon()
    private var mnemonic = ""
    private var name = ""
    private var iCloudSecretStorage = false
    private var saltMnemonicOn = false
    private var salt = ""
    private var passwordType: KeyStoreItem.PasswordType = PIN
    private var password = ""
    private var passUnlockWithBio = false
    private var selectedLocation = 0
    private var ctaTapped = false

    override fun present() { updateView() }

    override fun handle(event: MnemonicImportPresenterEvent) {
        when (event) {
            is MnemonicImportPresenterEvent.MnemonicChanged -> {
                val result = common.clearBlanksFromFrontOf(event.to, event.selectedLocation)
                mnemonic = result.first
                selectedLocation = result.second
                updateView(event.to != mnemonic)
            }
            is MnemonicImportPresenterEvent.DidChangeName -> {
                name = event.name
            }
            is MnemonicImportPresenterEvent.DidChangeICouldBackup -> {
                iCloudSecretStorage = event.onOff
            }
            is MnemonicImportPresenterEvent.SaltSwitchDidChange -> {
                saltMnemonicOn = event.onOff
            }
            is MnemonicImportPresenterEvent.DidChangeSalt -> {
                salt = event.salt
            }
            is MnemonicImportPresenterEvent.SaltLearnMoreAction -> {
                wireframe.navigate(MnemonicImportWireframeDestination.LearnMoreSalt)
            }
            is MnemonicImportPresenterEvent.PassTypeDidChange -> {
                passwordType = passwordTypes()[event.idx]
                updateView()
            }
            is MnemonicImportPresenterEvent.PasswordDidChange -> {
                password = event.text
            }
            is MnemonicImportPresenterEvent.AllowFaceIdDidChange -> {
                passUnlockWithBio = event.onOff
            }
            is MnemonicImportPresenterEvent.DidTapMnemonic -> {
                interactor.pasteToClipboard(mnemonic.trim())
            }
            is MnemonicImportPresenterEvent.DidSelectCta -> {
                ctaTapped = true
                if (!isValidForm) return updateView()
                if (passwordType == KeyStoreItem.PasswordType.BIO) {
                    password = interactor.generatePassword()
                }
                try {
                    val item = interactor.createKeyStoreItem(keyStoreItemData, password, salt)
                    context.handler(item)
                    wireframe.navigate(Dismiss)
                } catch (e: Throwable) {
                    // TODO: Handle error
                }
            }
            is MnemonicImportPresenterEvent.DidSelectDismiss -> {
                wireframe.navigate(Dismiss)
            }
        }
    }

    private val keyStoreItemData: MnemonicImportInteractorData get() = MnemonicImportInteractorData(
        mnemonic.trim().split(" "),
        name,
        passUnlockWithBio,
        iCloudSecretStorage,
        saltMnemonicOn,
        passwordType
    )

    private fun updateView(updateMnemonic: Boolean = false) {
        view.get()?.update(viewModel(updateMnemonic))
    }

    private fun viewModel(updateMnemonic: Boolean = false): MnemonicImportViewModel {
        val sections = mutableListOf<Section>()
        val error = interactor.mnemonicError(mnemonic.trim().split(" "), salt)
        sections.add(mnemonicSection(updateMnemonic, error))
        if (error == null) { sections.add(optionsSection()) }
        return MnemonicImportViewModel(
            sections,
            Localized("mnemonic.cta.import"),
        )
    }

    private fun mnemonicSection(updateMnemonic: Boolean, error: MnemonicServiceError?): Section =
        Section(
            listOf(mnemonicItem(updateMnemonic)),
            mnemonicFooterDefault(),
            // mnemonicFooter(error)
        )

    private fun mnemonicItem(updateMnemonic: Boolean): Section.Item {
        val common = MnemonicPresenterCommon()
        val prefixForPotentialWords = common.findPrefixForPotentialWords(mnemonic, selectedLocation)
        val potentialWords = interactor.potentialMnemonicWords(prefixForPotentialWords)
        var wordsInfo = interactor.findInvalidWords(mnemonic)
        wordsInfo = common.updateWordsInfo(wordsInfo, prefixForPotentialWords, selectedLocation) {
            interactor.isValidPrefix(it)
        }
        val isMnemonicValid = interactor.isMnemonicValid(mnemonic.trim(), salt)
        return Section.Item.Mnemonic(
            Section.Mnemonic(
                potentialWords,
                wordsInfo.map { WordInfo(it.word, it.isInvalid) },
                if (ctaTapped) isMnemonicValid else null,
                if (updateMnemonic) mnemonic else null,
            )
        )
    }

    private fun mnemonicFooter(error: MnemonicServiceError?): SectionFooterViewModel = error?.let {
        return mnemonicFooterError(it)
    }.run {
        mnemonicFooterDefault()
    }

    private fun mnemonicFooterDefault(): SectionFooterViewModel = SectionFooterViewModel(
        Localized("mnemonic.footer"),
        listOf(
            Localized("mnemonic.footerHighlightWord0"),
            Localized("mnemonic.footerHighlightWord1"),
        )
    )

    private fun mnemonicFooterError(error: MnemonicServiceError): SectionFooterViewModel =
        when (error) {
            MnemonicServiceError.INVALID_WORD_COUNT -> {
                SectionFooterViewModel(
                    Localized("mnemonic.error.invalid.wordCount"),
                    listOf(
                        Localized("mnemonic.error.invalid.wordCount.highlight0")
                    )
                )
            }
            MnemonicServiceError.OTHER -> {
                SectionFooterViewModel(
                    Localized("mnemonic.error.invalid"),
                    listOf(
                        Localized("mnemonic.error.invalid")
                    )
                )
            }
        }

    private fun optionsSection(): Section = Section(
        optionSectionsItems(),
        null
    )

    private fun optionSectionsItems(): List<Section.Item> = listOf(
        Section.Item.TextInput(
            TextInputCollectionViewModel(
                Localized("mnemonic.name.title"),
                name,
                Localized("mnemonic.name.placeholder"),
            )
        ),
        Section.Item.Switch(
            SwitchCollectionViewModel(
                Localized("mnemonic.iCould.title"),
                iCloudSecretStorage,
            )
        ),
//        Section.Item.SwitchWithTextInput(
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
        Section.Item.SegmentWithTextAndSwitchInput(
            SegmentWithTextAndSwitchCellViewModel(
                Localized("mnemonic.passType.title"),
                passwordTypes().map { it.name.lowercase() },
                selectedPasswordTypeIdx(),
                password,
                if (passwordType == PIN) NUMBER_PAD else DEFAULT,
                Localized("mnemoniw.$placeholderType.placeholder"),
                passwordErrorMessage,
                Localized("mnemonic.passType.allowFaceId"),
                passUnlockWithBio,
            )
        )
    )

    private val placeholderType: String get() = if (passwordType == PIN) "pinType" else "passType"

    private fun passwordTypes(): List<KeyStoreItem.PasswordType> =
        KeyStoreItem.PasswordType.values().map { it }

    private fun selectedPasswordTypeIdx(): Int {
        val index = passwordTypes().indexOf(passwordType)
        return if (index == -1) return 2 else index
    }

    private val isValidForm: Boolean get() = passwordErrorMessage == null

    private val passwordErrorMessage: String? get() {
        if (!ctaTapped) return null
        return interactor.validationError(password, passwordType)
    }
}
