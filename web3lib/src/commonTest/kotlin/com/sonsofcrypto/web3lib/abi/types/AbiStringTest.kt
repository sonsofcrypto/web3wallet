package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class AbiStringTest {
    @Test
    fun testAbiString() {
        assertFalse(AbiString.isType("int"))
        assertFalse(AbiString.isType("tuple"))

        assertTrue(AbiString.isType("string"))
        assertFalse(AbiString.isType("string[]"))

        val actual = AbiString("string", "Hello, world!")
        assertTrue(actual.isDynamic())
        assertEquals("string", actual.type)
        assertEquals("000000000000000000000000000000000000000000000000000000000000000d" +
                    "48656c6c6f2c20776f726c642100000000000000000000000000000000000000", actual.encode().toHexString())
    }
}