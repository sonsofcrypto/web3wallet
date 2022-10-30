package com.sonsofcrypto.web3lib.abi

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.setReturnValue
import kotlin.test.Test
import kotlin.test.assertEquals

class CallStackTest {

    @Test
    fun testStackCultDao() {
        setReturnValue("e2bbb158ea830e9efa91fa2a38c9708f9f6109a6c571d6a762b53a83776a3d67")
        val actual = CallStack("deposit(uint256,uint256)")
            .addVariable(0, BigInt.from("0")) // _pid (uint256)
            .addVariable(1, BigInt.from("87348030907832289007691499") //_amount (uint256)
        ).toString()
        assertEquals(
            "e2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb",
            actual
        )
    }

    @Test
    fun testStack() {
        setReturnValue("e2bbb158ea830e9efa91fa2a38c9708f9f6109a6c571d6a762b53a83776a3d67")
        val actual = CallStack("deposit(uint256,uint256)")
            .addVariable(0, BigInt.from("0")) // _pid (uint256)
            .addVariable(1, BigInt.from("87348030907832289007691499") //_amount (uint256)
            ).toString()
        assertEquals(
            "e2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb",
            actual
        )
    }


    @Test
    fun testStackArray() {
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

        val call = CallStack("deposit(uint256,uint256)")
            .addVariable(0, actual).toAbiEncodedString()

        val expected =
                "e2bbb158" +
                "0000000000000000000000000000000000000000000000000000000000000040" +
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

        assertEquals(expected, call)
    }
}