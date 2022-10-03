package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import kotlin.test.Test
import kotlin.test.assertTrue

class CommonGreetingTest {

    @Test
    fun testExample() {
        val bip39 = Bip39.from(Bip39.EntropySize.ES128)
        println("${bip39.mnemonic}")
        assertTrue("Hello".contains("Hello"), "Check 'Hello' is mentioned")
    }
}