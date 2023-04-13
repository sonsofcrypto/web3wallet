package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.Trie
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.words
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import kotlin.test.Test
import kotlin.test.assertEquals

class TrieTest {

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun testWordSearch() {
        val trie = Trie()
        WordList.ENGLISH.words().forEach { trie.insert(it) }
        ProtoBuf.encodeToByteArray(trie).toHexString()
        val result = trie.wordsStartingWith("ag")
        assertEquals(
            result,
            listOf("again", "age", "agent", "agree"),
            "Trie search epic fail, trie implementation broken"
        )
    }
}