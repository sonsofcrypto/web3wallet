package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlin.test.Test
import kotlin.test.assertEquals

class AbiTupleTest {
    @Test
    fun testTuple() {
        val actual = AbiTuple("tuple(uint, uint)", arrayOf(
            123,
            321
        ))
        println(actual.encode().toHexString())
        assertEquals("", actual.encode().toHexString())
    }
}