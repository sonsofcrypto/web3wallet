package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.setReturnValue
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import io.ktor.utils.io.core.*
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

    @Test
    fun testEncodeCallSignature() {
        // Mock return value of crypto functions
        setReturnValue("70a08231b98ef4ca268c9cc3f6b4590e4bfec28280db06bb5d45e689f2a360be")
        val actual = AbiEncode.encodeCallSignature("balanceOf(address)")
        assertEquals("70a08231", actual.toHexString())
    }

    @Test
    fun testEncodeCallSignature2() {
        // Mock return value of crypto functions
        setReturnValue("cdcd77c0992ec5bbfc459984220f8c45084cc24d9b6efed1fae540db8de801d2")
        val actual = AbiEncode.encodeCallSignature("baz(uint32,bool)")
        assertEquals("cdcd77c0", actual.toHexString())
    }
}