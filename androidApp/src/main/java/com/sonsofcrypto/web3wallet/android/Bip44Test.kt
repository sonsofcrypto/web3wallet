package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib_bip44.*
import com.sonsofcrypto.web3lib_crypto.*
import com.sonsofcrypto.web3lib_extensions.*
import java.lang.Exception

class Bip44Test {

    val seed = """
            826764960a59f2705fffff445ee2f33cb539d270d6c7c3773107acf3e91c508c
            93e00e395492a1f6238e2dda6f7142b7eefd0e114e23e618e6d6fdbeda8b5dfd
        """.trimIndent().replace("\n", "")

    var xprv = """
        xprv9s21ZrQH143K3vzEmTsVh32LojJ7b2xJBmrgyqVjqwbHEaRqGkQ1mxTrch59AiN2
        5ztNS2EzLCz5G7vE42VCtVnvCUEpYdDnbZFZJyEodkH
    """.trimIndent().replace("\n", "")

    fun runAll() {
        setup()
        testBip44MasterKey()
    }

    fun setup() {
        Crypto.setProvider(AndroidCryptoPrimitivesProvider())
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testBip44MasterKey() {
        val bip44 = Bip44(seed.hexStringToByteArray(), Bip44.Version.MAINNETPRV)
        assertTrue(
            bip44.masterExtKey.base58WithChecksumString() == xprv,
            "xprv does not match expected"
        )


        val child = bip44.deviceChildKey("m/44'/60'/0'/0/0")
    }
}