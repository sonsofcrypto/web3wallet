package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidGreetingTest {

    @Test
    fun testExample() {
        println("=== Running android test")
        val bip39 = Bip39.from(Bip39.EntropySize.ES128)
        println(bip39.worldList)
        assertTrue("Check Android is mentioned", "Android".contains("Android"))
    }
}