package com.sonsofcrypto.web3lib.abi

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.setReturnValue
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertTrue

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
    fun testEncodeString() {
        val actual = AbiEncode.encode("Hello, world!").toHexString()
        val expected = "000000000000000000000000000000000000000000000000000000000000000d" +
                       "48656c6c6f2c20776f726c642100000000000000000000000000000000000000"

        assertEquals(expected, actual)
    }

    @Test
    fun testEncodeAddress () {
        val actual = AbiEncode.encode(Address.HexString("2d77b594b9bbaed03221f7c63af8c4307432daf1"))
        assertEquals("0000000000000000000000002d77b594b9bbaed03221f7c63af8c4307432daf1", actual.toHexString())
    }

    @Test
    fun testEncodeDynamicArrayOfStrings () {
        val actual = AbiEncode.encode(arrayOf(
            AbiEncode.encode("one"),
            AbiEncode.encode("two"),
            AbiEncode.encode("three")
        ))
        val expected =  "0000000000000000000000000000000000000000000000000000000000000060" +
                        "00000000000000000000000000000000000000000000000000000000000000a0" +
                        "00000000000000000000000000000000000000000000000000000000000000e0" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "6f6e650000000000000000000000000000000000000000000000000000000000" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "74776f0000000000000000000000000000000000000000000000000000000000" +
                        "0000000000000000000000000000000000000000000000000000000000000005" +
                        "7468726565000000000000000000000000000000000000000000000000000000"

        assertTrue(expected.hexStringToByteArray().contentEquals(actual))
    }

    @Test
    fun testEncodeDynamicArrayOfInts () {
        val actual = AbiEncode.encode(arrayOf(
            AbiEncode.encode(1),
            AbiEncode.encode(2),
            AbiEncode.encode(3)
        ))
        val expected =  "0000000000000000000000000000000000000000000000000000000000000060" +
                        "0000000000000000000000000000000000000000000000000000000000000080" +
                        "00000000000000000000000000000000000000000000000000000000000000a0" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000003"

        assertTrue(expected.hexStringToByteArray().contentEquals(actual))
    }

    @Test
    fun testEncodeDynamicArrayOfIntsAndStrings () {
        val actual = AbiEncode.encode(arrayOf(
            AbiEncode.encode(1),
            AbiEncode.encode("two"),
            AbiEncode.encode(3),
            AbiEncode.encode("four"),
        ))

        val expected =  "0000000000000000000000000000000000000000000000000000000000000080" +
                        "00000000000000000000000000000000000000000000000000000000000000a0" +
                        "00000000000000000000000000000000000000000000000000000000000000e0" +
                        "0000000000000000000000000000000000000000000000000000000000000100" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "74776f0000000000000000000000000000000000000000000000000000000000" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "0000000000000000000000000000000000000000000000000000000000000004" +
                        "666f757200000000000000000000000000000000000000000000000000000000"
        assertTrue(expected.hexStringToByteArray().contentEquals(actual))
    }

    @Test
    fun testEncodeStaticArrayOfInts () {
        val actual = AbiEncode.encode(arrayOf(
            BigInt.from(1),
            BigInt.from(2)
        ))

        val expected =  "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000002"

        assertTrue(expected.hexStringToByteArray().contentEquals(actual))
    }

    @Test
    fun testEncodeStaticArrayOfArrays () {
        val array1 = AbiEncode.encode(arrayOf(
            BigInt.from(1),
            BigInt.from(2)
        ))
        val array2 = AbiEncode.encode(arrayOf(
            BigInt.from(3)
        ))

        val actual = AbiEncode.encode(arrayOf(
            array1,
            array2
        ))

        val expected =  "0000000000000000000000000000000000000000000000000000000000000040" +
                        "00000000000000000000000000000000000000000000000000000000000000a0" +
                        "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000003"

        assertTrue(expected.hexStringToByteArray().contentEquals(actual))
    }

    @Test
    fun testEncodeStaticAndDynamicArrayOfArrays () {
        val staticArray1 = AbiEncode.encode(arrayOf(
            BigInt.from(1),
            BigInt.from(2)
        ))

        val staticArray2 = AbiEncode.encode(arrayOf(
            BigInt.from(3)
        ))

        val staticArray = AbiEncode.encode(arrayOf(
            staticArray1,
            staticArray2
        ), true)

        val dynamicArray = AbiEncode.encode(arrayOf(
            AbiEncode.encode("one"),
            AbiEncode.encode("two"),
            AbiEncode.encode("three")
        ), true)

        val actual = AbiEncode.encode(arrayOf(
            staticArray,
            dynamicArray
        ))

        val expected =  "0000000000000000000000000000000000000000000000000000000000000040" +
                        "0000000000000000000000000000000000000000000000000000000000000140" +
                        "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000040" +
                        "00000000000000000000000000000000000000000000000000000000000000a0" +
                        "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000002" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "0000000000000000000000000000000000000000000000000000000000000060" +
                        "00000000000000000000000000000000000000000000000000000000000000a0" +
                        "00000000000000000000000000000000000000000000000000000000000000e0" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "6f6e650000000000000000000000000000000000000000000000000000000000" +
                        "0000000000000000000000000000000000000000000000000000000000000003" +
                        "74776f0000000000000000000000000000000000000000000000000000000000" +
                        "0000000000000000000000000000000000000000000000000000000000000005" +
                        "7468726565000000000000000000000000000000000000000000000000000000"

        assertTrue(expected.hexStringToByteArray().contentEquals(actual))
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
            "0xcdcd77c0" +
                    "0000000000000000000000000000000000000000000000000000000000000045" +
                    "0000000000000000000000000000000000000000000000000000000000000001",
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
            "0xe2bbb158" + // deposit(uint256,uint256)
                    "0000000000000000000000000000000000000000000000000000000000000000" + // 0
                    "0000000000000000000000000000000000000000004840aa3e5e8b722426e6eb", // bigint
            actual
        )
    }

    @Test
    fun testLeftPad() {
        val expected1 = "0000000000000000000000000000000000000000000000000000000000123123".hexStringToByteArray()
        val actual1 = AbiEncode.leftPadZeros("123123".hexStringToByteArray())
        assertContentEquals(expected1, actual1)
    }


    @Test
    fun testRightPad() {
        val expected1 = "1231230000000000000000000000000000000000000000000000000000000000".hexStringToByteArray()
        val actual1 = AbiEncode.rightPadZeros("123123".hexStringToByteArray())
        assertContentEquals(expected1, actual1)
    }

    @Test
    fun testEncodeWithMultiple() {
        val actual = AbiEncode.encode(
            arrayOf(
                "string",
                "address",
                "bool",
                "uint16",
                "uint"
            ),
            arrayOf(
                "Hello, world!",
                "0x2d77b594b9bbaed03221f7c63af8c4307432daf1",
                true,
                500,
                "123123123123123123123123123"
            )).toHexString()
        val expected =  "000000000000000000000000000000000000000000000000000000000000000d" +
                        "48656c6c6f2c20776f726c642100000000000000000000000000000000000000" +
                        "0000000000000000000000002d77b594b9bbaed03221f7c63af8c4307432daf1" +
                        "0000000000000000000000000000000000000000000000000000000000000001" +
                        "00000000000000000000000000000000000000000000000000000000000001f4" +
                        "00000000000000000000000000000000000000000065d855e0f02863c04ff3b3"

        assertEquals(expected, actual)
    }
    @Test
    fun testEncodeWithTypeString() {
        val actual = AbiEncode.encode("string", "Hello, world!").toHexString()
        val expected =  "000000000000000000000000000000000000000000000000000000000000000d" +
                        "48656c6c6f2c20776f726c642100000000000000000000000000000000000000"

        assertEquals(expected, actual)
    }
    @Test
    fun testEncodeWithTypeAddressW0x() {
        val actual = AbiEncode.encode("address", "0x2d77b594b9bbaed03221f7c63af8c4307432daf1").toHexString()
        val expected =  "0000000000000000000000002d77b594b9bbaed03221f7c63af8c4307432daf1"

        assertEquals(expected, actual)
    }

    @Test
    fun testEncodeWithTypeAddress() {
        val actual = AbiEncode.encode("address", "2d77b594b9bbaed03221f7c63af8c4307432daf1").toHexString()
        val expected =  "0000000000000000000000002d77b594b9bbaed03221f7c63af8c4307432daf1"

        assertEquals(expected, actual)
    }
    @Test
    fun testEncodeWithTypeTuple() {
        val actual = AbiEncode.encode(
            "tuple(string message, address to)",
            arrayOf("Hello, world!", "0x2d77b594b9bbaed03221f7c63af8c4307432daf1")
        ).toHexString()
        val expected =  "000000000000000000000000000000000000000000000000000000000000000d" +
                        "48656c6c6f2c20776f726c642100000000000000000000000000000000000000" +
                        "0000000000000000000000002d77b594b9bbaed03221f7c63af8c4307432daf1"

        assertEquals(expected, actual)
    }
}