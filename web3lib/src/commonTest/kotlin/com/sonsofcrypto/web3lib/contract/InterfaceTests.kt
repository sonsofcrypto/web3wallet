package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.Resource
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.keccak256
import io.ktor.utils.io.core.*
import kotlin.test.Test
import kotlin.test.assertEquals

class InterfaceTests {

    @Test
    fun testMAXEthereum1() {
        val res = Resource("contractsJson/IERC20.json").exists()
        println("=== Exits $res")
    }
}