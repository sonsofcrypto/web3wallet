package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.mnemonic.MnemonicPresenterCommon
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationViewModel.WordInfo
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationWireframeDestination.Dismiss

sealed class MnemonicConfirmationPresenterEvent {
    object Dismiss: MnemonicConfirmationPresenterEvent()
    data class MnemonicChanged(
        val to: String, val selectedLocation: Int
    ): MnemonicConfirmationPresenterEvent()
    data class SaltChanged(val to: String): MnemonicConfirmationPresenterEvent()
    object Confirm: MnemonicConfirmationPresenterEvent()
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
    private var selectedLocation = 0
    private var ctaTapped = false
    private val common = MnemonicPresenterCommon()

    override fun present() { updateView() }

    override fun handle(event: MnemonicConfirmationPresenterEvent) {
        when (event) {
            is MnemonicConfirmationPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
            is MnemonicConfirmationPresenterEvent.MnemonicChanged -> {
                val result = common.clearBlanksFromFrontOf(event.to, event.selectedLocation)
                mnemonic = result.first
                selectedLocation = result.second
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
                interactor.markDashboardNotificationAsComplete()
                wireframe.navigate(Dismiss)
            }
        }
    }

    private fun updateView(updateMnemonic: Boolean = false) {
        view.get()?.update(viewModel(updateMnemonic))
    }

    private fun viewModel(updateMnemonic: Boolean = false): MnemonicConfirmationViewModel {
        val prefixForPotentialWords = common.findPrefixForPotentialWords(mnemonic, selectedLocation)
        val potentialWords = interactor.potentialMnemonicWords(prefixForPotentialWords)
        var wordsInfo = interactor.findInvalidWords(mnemonic)
        wordsInfo = common.updateWordsInfo(wordsInfo, prefixForPotentialWords, selectedLocation) {
            interactor.isValidPrefix(it)
        }
        val isMnemonicValid = interactor.isMnemonicValid(mnemonic.trim(), salt)
        return MnemonicConfirmationViewModel(
            potentialWords,
            wordsInfo.map { WordInfo(it.word, it.isInvalid) },
            if (ctaTapped) isMnemonicValid else null,
            if (updateMnemonic) mnemonic else null,
            interactor.showSalt()
        )
    }
}
