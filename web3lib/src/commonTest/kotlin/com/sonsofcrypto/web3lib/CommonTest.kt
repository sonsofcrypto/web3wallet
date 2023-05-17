package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import kotlin.test.Test
import kotlin.test.assertEquals

class CommonTest {

    @Test
    fun testCoreCryptoLinking() {
        val entropy = "0x0daee99c02cea52888763ea8443e6c4e".hexStringToByteArray()
        var bip39 = Bip39.from(entropy)
        val expectation = listOf(
            "asset", "jar", "grow", "airport", "tumble", "nephew", "canyon",
            "sick", "portion", "capable", "only", "oven"
        )
        assertEquals(
            expectation.joinToString(),
            bip39.mnemonic.joinToString(),
            "Unexpected mnemonic ${bip39.mnemonic}, expected $expectation"
        )
    }
}