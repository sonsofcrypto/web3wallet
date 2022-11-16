package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.utils.WeakRef
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
    private var ctaTapped = false
    private var mnemonic = ""
    private var salt = ""
    private var selectedLocation = 0

    override fun present() { updateView() }

    override fun handle(event: MnemonicConfirmationPresenterEvent) {
        when (event) {
            is MnemonicConfirmationPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
            is MnemonicConfirmationPresenterEvent.MnemonicChanged -> {
                val result = clearBlanksFromFrontOf(event.to, event.selectedLocation)
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

    private fun viewModel(updateMnemonic: Boolean = false): MnemonicConfirmationViewModel{
        val prefixForPotentialWords = findPrefixForPotentialWords(mnemonic, selectedLocation)
        val potentialWords = interactor.potentialMnemonicWords(prefixForPotentialWords)
        var wordsInfo = interactor.findInvalidWords(mnemonic)
        wordsInfo = updateWordsInfo(wordsInfo, prefixForPotentialWords, selectedLocation)
        val isMnemonicValid = interactor.isMnemonicValid(mnemonic.trim(), salt)
        return MnemonicConfirmationViewModel(
            potentialWords,
            wordsInfo,
            if (ctaTapped) isMnemonicValid else null,
            if (updateMnemonic) mnemonic else null,
            interactor.showSalt()
        )
    }

    private fun findPrefixForPotentialWords(mnemonic: String, selectedLocation: Int): String {
        var prefix = ""
        for (i in 0 until mnemonic.count()) {
            val char = mnemonic[i]
            if (i == selectedLocation) { return prefix }
            prefix += char
            if (char == ' ') { prefix = "" }
        }
        return prefix
    }

    private fun updateWordsInfo(
        wordsInfo: List<WordInfo>,
        prefixForPotentialwords: String,
        selectedLocation: Int
    ): List<WordInfo> {
        val updatedWords = mutableListOf<WordInfo>()
        var location = 0
        var wordUpdated = false
        for (i in 0  until wordsInfo.count()) {
            val wordInfo = wordsInfo[i]
            location += wordInfo.word.count()
            if (selectedLocation <= location && !wordUpdated) {
                if (wordInfo.word == prefixForPotentialwords) {
                    val isInvalid =
                        if (i > 11) wordInfo.isInvalid
                        else !interactor.isValidPrefix(wordInfo.word)
                    updatedWords.add(WordInfo(wordInfo.word, isInvalid))
                }
                wordUpdated = true
            } else {
                updatedWords.add(wordInfo)
            }
            location += 1
        }
        return updatedWords
    }

    private fun clearBlanksFromFrontOf(
        mnemonic: String, selectedLocation: Int
    ): Pair<String, Int> {
        val initialCount = mnemonic.count()
        mnemonic.firstOrNull { !(it == ' ' || it == '\t' || it == '\n') }?.let { c ->
            val index = mnemonic.indexOf(c)
            if (index != -1) {
                mnemonic.replaceRange(IntRange(0, index - 1), "")
            }
        }
        val finalCount = mnemonic.count()
        val pair = Pair(mnemonic, (selectedLocation - (initialCount - finalCount)))
        return pair
    }
}
