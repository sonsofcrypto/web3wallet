package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlin.test.Test
import kotlin.test.assertEquals

class AbiEncodeTest {
    @Test
    fun testEncodeBooleanTrue () {
        val actual = AbiEncode.encode(true)
        assertEquals("0000000000000000000000000000000000000000000000000000000000000001", actual.toHexString())
    }

    @Test
    fun testEncodeBooleanFalse () {
        val actual = AbiEncode.encode(false)
        assertEquals("0000000000000000000000000000000000000000000000000000000000000000", actual.toHexString())
    }

    @Test
    fun testEncodeInt () {
        val actual = AbiEncode.encode(100)
        assertEquals("0000000000000000000000000000000000000000000000000000000000000064", actual.toHexString())
    }

    @Test
    fun testEncodeLong () {
        val actual = AbiEncode.encode(100.toLong())
        assertEquals("0000000000000000000000000000000000000000000000000000000000000064", actual.toHexString())
    }

    @Test
    fun testEncodeUint () {
        val actual = AbiEncode.encode(100u)
        assertEquals("0000000000000000000000000000000000000000000000000000000000000064", actual.toHexString())
    }

    @Test
    fun testEncodeBigInt () {
        val actual = AbiEncode.encode(BigInt.from(100))
        assertEquals("0000000000000000000000000000000000000000000000000000000000000064", actual.toHexString())
    }
/*
    @Test
    fun testAbiFunction() {
        val actual = AbiEncode.encodeCall("balanceOf(address)")
        println(actual.toHexString())
        assertEquals("0x70a08231", actual.toHexString())
    }
 */
}