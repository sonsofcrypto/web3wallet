package com.sonsofcrypto.web3walletcore.common.mnemonic

import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord

class MnemonicPresenterCommon {

    fun findPrefixForPotentialWords(mnemonic: String, selectedLocation: Int): String {
        var prefix = ""
        for (i in 0 until mnemonic.count()) {
            val char = mnemonic[i]
            if (i == selectedLocation) { return prefix }
            prefix += char
            if (char == ' ') { prefix = "" }
        }
        return prefix
    }

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
                    val isInvalid =
                        if (i > 11) wordInfo.isInvalid
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

    fun clearBlanksFromFrontOf(mnemonic: String, selectedLocation: Int): Pair<String, Int> {
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