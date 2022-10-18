package com.sonsofcrypto.web3lib.provider.model

import com.sonsofcrypto.web3lib.utils.BigInt
import kotlin.test.Test
import kotlin.test.assertEquals

class QuantityDataHexStringTest {
    @Test
    fun testQuantitiesLong() {
        val actual = QuantityHexString(10000000000)
        assertEquals("0x2540be400", actual)
    }
    @Test
    fun testQuantitiesUInt() {
        val actual = QuantityHexString(10000000000u)
        assertEquals("0x2540be400", actual)
    }
    @Test
    fun testQuantitiesBigInt() {
        val actual = QuantityHexString(BigInt.Companion.from(10000000000))
        assertEquals("0x2540be400", actual)
    }
    @Test
    fun testQuantitiesZero() {
        val actual = QuantityHexString(0)
        assertEquals("0x0", actual)
    }

    @Test
    fun testDataHexString() {
        val actual = DataHexString(ByteArray(10))
        assertEquals("0x00000000000000000000", actual)
    }
    @Test
    fun testDataHexStringZero() {
        val actual = DataHexString(ByteArray(1))
        assertEquals("0x00", actual)
    }
    @Test
    fun testDataHexStringNil() {
        val actual = DataHexString(ByteArray(0))
        assertEquals("0x", actual)
    }
}