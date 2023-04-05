package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.*
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidGreetingTest {

    @Test
    fun testExample() {
        println("=== Running android test")
//        var result = Foolib.Hello("your mum")
//        var result = Foolib.Hello("your mum")
//        val result = CoreCrypto.secureRand(12)
        var bip39 = Bip39.from()
        val result = bip39.mnemonic
        println("=== RESULT $result")
        assertTrue("Check Android is mentioned", "Android".contains("Android"))
    }
}