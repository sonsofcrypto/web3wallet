package com.sonsofcrypto.web3lib_bip39

import com.sonsofcrypto.web3lib_crypto.Crypto
import kotlin.test.Test
import kotlin.test.assertTrue

class CommonBip39Test {

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
        assertTrue(true)
    }
}
