package com.sonsofcrypto.web3lib

//import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import go.coreCrypto.CoreCrypto
//import go.foolib.Foolib
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidGreetingTest {

    @Test
    fun testExample() {
        println("=== Running android test")
//        var result = Foolib.Hello("your mum")
//        var result = Foolib.Hello("your mum")
        val result = CoreCrypto.SecureRand(12)
        println("=== RESULT $result")
        assertTrue("Check Android is mentioned", "Android".contains("Android"))
    }
}