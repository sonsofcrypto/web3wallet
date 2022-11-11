package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class AbiNumberTest {
    @Test
    fun testNumber() {
        assertFalse(AbiNumber.isType("string"))
        assertFalse(AbiNumber.isType("tuple"))

        assertTrue(AbiNumber.isType("int"))
        assertFalse(AbiNumber.isType("int[]"))
        assertTrue(AbiNumber.isType("int8"))
        assertTrue(AbiNumber.isType("int160"))
        assertTrue(AbiNumber.isType("int256"))
        assertTrue(AbiNumber.isType("uint"))
        assertTrue(AbiNumber.isType("uint8"))
        assertTrue(AbiNumber.isType("uint160"))
        assertTrue(AbiNumber.isType("uint256"))

        val actual = AbiNumber("uint", 123123)
        assertEquals("uint", actual.type)
        assertFalse(actual.isDynamic())
        assertEquals("000000000000000000000000000000000000000000000000000000000001e0f3", actual.encode().toHexString())
    }
}