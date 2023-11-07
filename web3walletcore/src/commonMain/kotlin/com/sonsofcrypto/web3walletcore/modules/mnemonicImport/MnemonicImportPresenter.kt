package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.PIN
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicPresenterHelper
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.DEFAULT
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.SegmentWithTextAndSwitch.KeyboardType.NUMBER_PAD
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicServiceError
import com.sonsofcrypto.web3lib.utils.extensions.stripLeadingWhiteSpace
import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicInputViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel

sealed class MnemonicImportPresenterEvent {
    data class MnemonicChanged(val to: String, val cursorLocation: Int): MnemonicImportPresenterEvent()
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
    private val helper = MnemonicPresenterHelper()
    private var mnemonic = ""
    private var name = ""
    private var iCloudSecretStorage = false
    private var saltMnemonicOn = false
    private var salt = ""
    private var passwordType: SignerStoreItem.PasswordType = BIO
    private var password = ""
    private var passUnlockWithBio = true
    private var cursorLocation = 0
    private var ctaTapped = false

    override fun present() { updateView() }

    override fun handle(event: MnemonicImportPresenterEvent): Unit =  when (event) {
        is MnemonicImportPresenterEvent.MnemonicChanged -> {
            mnemonic = event.to.stripLeadingWhiteSpace()
            cursorLocation = event.cursorLocation -
                (event.to.count() - mnemonic.count())
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
            updateView()
        }
        is MnemonicImportPresenterEvent.AllowFaceIdDidChange -> {
            passUnlockWithBio = event.onOff
        }
        is MnemonicImportPresenterEvent.DidTapMnemonic -> {
            interactor.pasteToClipboard(mnemonic.trim())
        }
        is MnemonicImportPresenterEvent.DidSelectCta -> {
            ctaTapped = true
            if (!isValidForm) {
                updateView()
            } else {
                if (passwordType == SignerStoreItem.PasswordType.BIO) {
                    password = interactor.generatePassword()
                }
                try {
                    createDefaultNameIfNeeded()
                    val item = interactor
                        .createKeyStoreItem(keyStoreItemData, password, salt)
                    context.handler(item)
                    wireframe.navigate(Dismiss)
                } catch (e: Throwable) {
                    // TODO: Handle error
                }
            }
        }
        is MnemonicImportPresenterEvent.DidSelectDismiss -> {
            wireframe.navigate(Dismiss)
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
        view.get()?.update(viewModel(), mnemonicItem(updateMnemonic))
    }

    private fun viewModel(): CollectionViewModel.Screen {
        val error = interactor.mnemonicError(mnemonic.trim().split(" "), salt)
        var sections = mutableListOf(mnemonicSection(error))
        if (error == null)
            sections.add(optionsSection())
        return CollectionViewModel.Screen(
            Localized(""),
            sections,
            listOf(Localized("mnemonic.cta.import")),
        )
    }

    private fun mnemonicSection(err: MnemonicServiceError?): Section = Section(
        null,
        listOf(CellViewModel.Text(mnemonic)),
        mnemonicFooter(err),
    )

    // TODO: Clean up
    private fun mnemonicItem(updateMnemonic: Boolean): MnemonicInputViewModel {
        val helper = MnemonicPresenterHelper()
        val currentWord = interactor.prefix(mnemonic, cursorLocation)
        val potentialWords = interactor.potentialMnemonicWords(currentWord)
        var wordsInfo = interactor.findInvalidWords(mnemonic)
        wordsInfo = helper.updateWordsInfo(wordsInfo, currentWord, cursorLocation) {
            interactor.isValidPrefix(it)
        }
        val isMnemonicValid = interactor.isMnemonicValid(mnemonic.trim(), salt)
        return MnemonicInputViewModel(
            potentialWords,
            wordsInfo.map { MnemonicInputViewModel.Word(it.word, it.isInvalid) },
            if (ctaTapped) isMnemonicValid else null,
            if (updateMnemonic) mnemonic else null,
        )
    }

    private fun mnemonicFooter(error: MnemonicServiceError? = null): Footer {
        if (error == null)
            return HighlightWords(
                Localized("mnemonic.footer"),
                listOf(
                    Localized("mnemonic.footerHighlightWord0"),
                    Localized("mnemonic.footerHighlightWord1"),
                )
            )
        return when (error) {
            MnemonicServiceError.INVALID_WORD_COUNT -> HighlightWords(
                Localized("mnemonic.error.invalid.wordCount"),
                listOf(Localized("mnemonic.error.invalid.wordCount.highlight"))
            )
            MnemonicServiceError.OTHER -> HighlightWords(
                Localized("mnemonic.error.invalid"),
                listOf(Localized("mnemonic.error.invalid"))
            )
        }
    }

    private fun optionsSection(): Section = Section(
        null,
        listOf(
            CellViewModel.TextInput(
                Localized("mnemonic.name.title"),
                name,
                Localized("mnemonic.name.placeholder"),
            ),
            CellViewModel.Switch(
                Localized("mnemonic.iCould.title"),
                iCloudSecretStorage,
            ),
//        CellViewModel.SwitchWithTextInput(
//            Localized("mnemonic.salt.title"),
//            saltMnemonicOn,
//            salt,
//            Localized("mnemonic.salt.placeholder"),
//            Localized("mnemonic.salt.description"),
//            listOf(Localized("mnemonic.salt.descriptionHighlight")),
//        ),
            CellViewModel.SegmentWithTextAndSwitch(
                Localized("mnemonic.passType.title"),
                passwordTypes().map { it.name.lowercase() },
                selectedPasswordTypeIdx(),
                password,
                if (passwordType == PIN) NUMBER_PAD else DEFAULT,
                Localized("mnemonic.$placeholderType.placeholder"),
                passwordErrorMessage,
                Localized("mnemonic.passType.allowFaceId"),
                passUnlockWithBio,
            )
        ),
        null,
    )

    private val placeholderType: String get() = if (passwordType == PIN) "pinType" else "passType"

    private fun passwordTypes(): List<SignerStoreItem.PasswordType> =
        SignerStoreItem.PasswordType.values().map { it }

    private fun selectedPasswordTypeIdx(): Int {
        val index = passwordTypes().indexOf(passwordType)
        return if (index == -1) return 2 else index
    }

    private val isValidForm: Boolean get() {
        val isMnemonicValid = interactor.isMnemonicValid(mnemonic.trim(), salt)
        val isPasswordValid = passwordErrorMessage == null
        return isMnemonicValid && isPasswordValid
    }

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
