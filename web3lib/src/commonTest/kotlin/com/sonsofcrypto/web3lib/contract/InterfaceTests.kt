package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.types.Currency
import kotlin.test.Test
import kotlin.test.assertEquals

class InterfaceTests {

    @Test
    fun testMAXEthereum1() {

        val output = maxOutput("21000000000000000043", Currency.ethereum())
        assertEquals(listOf(Formatters.Output.Normal("21.000000000000000043 ETH")), output)
    }
}