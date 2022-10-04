package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.setReturnValue
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

    @Test
    fun testEncodeAddress () {
        val actual = AbiEncode.encode(Address.HexString("2d77b594b9bbaed03221f7c63af8c4307432daf1"))
        assertEquals("2d77b594b9bbaed03221f7c63af8c4307432daf1", actual.toHexString())
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

    @Test
    fun testEncodeFullCommand() {
        // Mock return value of crypto functions
        setReturnValue("cdcd77c0992ec5bbfc459984220f8c45084cc24d9b6efed1fae540db8de801d2")
        val a = AbiEncode.encodeCallSignature("baz(uint32,bool)").toHexString()
        val b = AbiEncode.encode(69).toHexString()
        val c = AbiEncode.encode(true).toHexString()

        val actual = "0x$a$b$c"

        assertEquals(
            "0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001",
            actual
        )
    }

    @Test
    fun testEncodeCultDaoDeposit() {
        // Mock return value of crypto functions
        setReturnValue("e2bbb158ea830e9efa91fa2a38c9708f9f6109a6c571d6a762b53a83776a3d67")
        val a = AbiEncode.encodeCallSignature("deposit(uint256,uint256)").toHexString()
        val b = AbiEncode.encode(0).toHexString()
        val c = AbiEncode.encode(BigInt.from("87348030907832289007691499")).toHexString()

        val actual = "0x$a$b$c"

        assertEquals(
            "0xe2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb",
            actual
        )
    }

}