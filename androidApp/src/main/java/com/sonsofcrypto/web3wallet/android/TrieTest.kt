package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib_utils.Trie
import com.sonsofcrypto.web3lib_utils.WordList
import com.sonsofcrypto.web3lib_utils.toHexString
import com.sonsofcrypto.web3lib_utils.words
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import java.lang.Exception

class TrieTest {

    fun runAll() {
        testWordSearch()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testWordSearch() {
        val trie = Trie()

        WordList.ENGLISH.words().forEach {
            trie.insert(it)
        }

        val bytes = ProtoBuf.encodeToByteArray(trie)
        val bytesString = bytes.toHexString()
        val result = trie.wordsStartingWith("ag")
        assertTrue(
            result == listOf("again", "age", "agent", "agree"),
            "Trie search epic fail, trie implementation broken"
        )
    }
}