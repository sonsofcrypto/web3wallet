package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class AbiArrayTest {
    @Test
    fun testStringArray() {
        assertTrue(AbiArray.isType("string[]"))
        val actual = AbiArray("string[]", arrayOf<String>("Hello, world!", "Hello, World!"))
        assertTrue(actual.isDynamic())

        assertEquals("0000000000000000000000000000000000000000000000000000000000000002" +
                "0000000000000000000000000000000000000000000000000000000000000040" +
                "0000000000000000000000000000000000000000000000000000000000000080" +
                "000000000000000000000000000000000000000000000000000000000000000d" +
                "48656c6c6f2c20776f726c642100000000000000000000000000000000000000" +
                "000000000000000000000000000000000000000000000000000000000000000d" +
                "48656c6c6f2c20776f726c642100000000000000000000000000000000000000", actual.encode().toHexString())
    }

    @Test
    fun testAddressArray() {
        assertTrue(AbiArray.isType("address[]"))
        val actual = AbiArray("address[]", arrayOf<String>("0xF1300cc9c2Cf347f7902742fEC4dF9dbA952fD7b", "0xF1300cc9c2Cf347f7902742fEC4dF9dbA952fD7b"))
        assertFalse(actual.isDynamic())
        assertEquals("0000000000000000000000000000000000000000000000000000000000000002" +
                "000000000000000000000000f1300cc9c2cf347f7902742fec4df9dba952fd7b" +
                "000000000000000000000000f1300cc9c2cf347f7902742fec4df9dba952fd7b", actual.encode().toHexString())
    }
}