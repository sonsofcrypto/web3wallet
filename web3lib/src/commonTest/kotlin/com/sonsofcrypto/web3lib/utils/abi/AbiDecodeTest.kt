package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.utils.BigInt
import kotlin.test.Test
import com.sonsofcrypto.web3lib.utils.abi.AbiDecode
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
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

    @Test
    fun testDecodeLong() {
        val actual = AbiDecode.decodeLong("00000000000000000000000000000000000000000000000007ffffffffffffff")
        assertEquals(BigInt.from(576460752303423487).toString(), actual.toString())
    }

    @Test
    fun testDecodeUInt16() {
        val actual = AbiDecode.decodeUInt16("00000000000000000000000000000000000000000000000000000000000003321")
        assertEquals(BigInt.from(13089u).toString(), actual.toString())
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