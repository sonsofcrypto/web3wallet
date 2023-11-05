package com.sonsofcrypto.web3walletcore.common.helpers

import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord

class MnemonicPresenterHelper {

    fun updateWordsInfo(
        wordsInfo: List<MnemonicWord>,
        prefixForPotentialWords: String,
        selectedLocation: Int,
        isValidPrefix: (String) -> Boolean
    ): List<MnemonicWord> {
        val updatedWords = mutableListOf<MnemonicWord>()
        var location = 0
        var wordUpdated = false
        for (i in 0  until wordsInfo.count()) {
            val wordInfo = wordsInfo[i]
            location += wordInfo.word.count()
            if (selectedLocation <= location && !wordUpdated) {
                if (wordInfo.word == prefixForPotentialWords) {
                    val isInvalid = if (i > 11) wordInfo.isInvalid
                        else !isValidPrefix(wordInfo.word)
                    updatedWords.add(MnemonicWord(wordInfo.word, isInvalid))
                }
                wordUpdated = true
            } else {
                updatedWords.add(wordInfo)
            }
            location += 1
        }
        return updatedWords
    }
}

data class MnemonicInputViewModel(
    val potentialWords: List<String>,
    val wordsInfo: List<Word>,
    val isValid: Boolean?,
    val mnemonicToUpdate: String?,
) {
    data class Word(val word: String, val isInvalid: Boolean, )
}
