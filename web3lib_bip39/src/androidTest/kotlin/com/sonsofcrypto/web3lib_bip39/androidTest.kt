package com.sonsofcrypto.web3lib_bip39

import com.sonsofcrypto.web3lib_crypto.*
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBip39Test {

    @Test
    fun testExample() {
        val words = listOf(
            "squeeze", "mention", "ostrich", "crunch", "maple", "liar", "aerobic", "brass", "vote",
            "young", "neither", "dune"
        )
        val salt = ""
        Crypto.setProvider(com.sonsofcrypto.web3lib_crypto.AndroidCryptoPrimitivesProvider())
        val bip39 = Bip39(words, salt, WordList.ENGLISH)
        val seed = bip39.seed()
        println("=== ${seed}")
        println("=== ${seed}")
        kotlin.test.assertTrue(true)
    }
}
