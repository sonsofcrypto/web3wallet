package com.sonsofcrypto.web3lib.utils.abi

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
            "0xe2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb",
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
            "0xe2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb",
            actual
        )
    }
}