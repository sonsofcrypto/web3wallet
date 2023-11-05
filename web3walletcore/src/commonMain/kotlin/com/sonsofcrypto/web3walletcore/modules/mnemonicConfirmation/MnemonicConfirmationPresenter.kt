package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.extensions.stripLeadingWhiteSpace
import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicInputViewModel
import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicPresenterHelper
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationWireframeDestination.Dismiss

sealed class MnemonicConfirmationPresenterEvent {
    object Dismiss: MnemonicConfirmationPresenterEvent()
    object Confirm: MnemonicConfirmationPresenterEvent()
    data class SaltChanged(val to: String): MnemonicConfirmationPresenterEvent()
    data class MnemonicChanged(
        val to: String,
        val cursorLocation: Int
    ): MnemonicConfirmationPresenterEvent()
}

interface MnemonicConfirmationPresenter {
    fun present()
    fun handle(event: MnemonicConfirmationPresenterEvent)
}

class DefaultMnemonicConfirmationPresenter(
    private val view: WeakRef<MnemonicConfirmationView>,
    private val wireframe: MnemonicConfirmationWireframe,
    private val interactor: MnemonicConfirmationInteractor
): MnemonicConfirmationPresenter {
    private var mnemonic = ""
    private var salt = ""
    private var cursorLocation = 0
    private var ctaTapped = false
    private val common = MnemonicPresenterHelper()

    override fun present() { updateView() }

    override fun handle(event: MnemonicConfirmationPresenterEvent) {
        when (event) {
            is MnemonicConfirmationPresenterEvent.Dismiss ->
                wireframe.navigate(Dismiss)
            is MnemonicConfirmationPresenterEvent.MnemonicChanged -> {
                mnemonic = event.to.stripLeadingWhiteSpace()
                cursorLocation = event.cursorLocation -
                        (event.to.count() -  mnemonic.count())
                updateView(event.to != mnemonic)
            }
            is MnemonicConfirmationPresenterEvent.SaltChanged -> {
                salt = event.to
                updateView()
            }
            is MnemonicConfirmationPresenterEvent.Confirm -> {
                if (!ctaTapped) {
                    ctaTapped = true
                    updateView()
                    return
                }
                if (!interactor.isMnemonicValid(mnemonic, salt)) {
                    updateView()
                    return
                }
                interactor.markConfirmActionComplete()
                wireframe.navigate(Dismiss)
            }
        }
    }

    private fun updateView(updateMnemonic: Boolean = false) {
        view.get()?.update(viewModel(updateMnemonic))
    }

    private fun viewModel(updateMnemonic: Boolean = false): MnemonicConfirmationViewModel {
        val prefixForPotentialWords = interactor.prefix(mnemonic, cursorLocation)
        val potentialWords = interactor.potentialMnemonicWords(prefixForPotentialWords)
        var wordsInfo = interactor.findInvalidWords(mnemonic)
        wordsInfo = common.updateWordsInfo(wordsInfo, prefixForPotentialWords, cursorLocation) {
            interactor.isValidPrefix(it)
        }
        val isMnemonicValid = interactor.isMnemonicValid(mnemonic.trim(), salt)
        return MnemonicConfirmationViewModel(
            potentialWords,
            wordsInfo.map { MnemonicInputViewModel.Word(it.word, it.isInvalid) },
            if (ctaTapped) isMnemonicValid else null,
            if (updateMnemonic) mnemonic else null,
            interactor.showSalt()
        )
    }
}
