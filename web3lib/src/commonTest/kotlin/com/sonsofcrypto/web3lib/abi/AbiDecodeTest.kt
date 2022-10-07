package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.utils.BigInt
import kotlin.test.Test
import kotlin.test.assertEquals

class AbiDecodeTest {

    @Test
    fun testDecodeBooleanTrue() {
        val actual = AbiDecode.decodeBoolean("0000000000000000000000000000000000000000000000000000000000000001")
        assertEquals(actual, true)
    }

    @Test
    fun testDecodeBooleanFalse() {
        val actual = AbiDecode.decodeBoolean("0000000000000000000000000000000000000000000000000000000000000000")
        assertEquals(actual, false)
    }


    @Test
    fun testDecodeInt() {
        val actual = AbiDecode.decodeInt("0000000000000000000000000000000000000000000000000000000000000045")
        assertEquals(BigInt.from(69).toString(), actual.toString())
    }

    fun testDecodeAddress() {
        val actual = AbiDecode.decodeAddress("c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2")
        assertEquals("000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", actual.toString())
    }

    @Test
    fun testDecodeWholeResponse() {
        var dataString = "0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
        dataString = dataString.removePrefix("0x")
        val signature = dataString.substring(0,8) // Signature
        val responses = dataString.substring(8,dataString.length).chunked(64) // Args (Int,Bool)

        assertEquals("cdcd77c0", signature)
        assertEquals(BigInt.from(69).toString(), AbiDecode.decodeInt(responses[0]).toString())
        assertEquals(true, AbiDecode.decodeBoolean(responses[1]))
    }
}