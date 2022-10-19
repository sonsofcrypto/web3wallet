package com.sonsofcrypto.web3lib.utils.abi.integrations

import com.sonsofcrypto.web3lib.abi.integrations.CultDao
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.setReturnValue
import kotlin.test.Test
import kotlin.test.assertEquals

class CultDaoTest {
    @Test
    fun testCultDaoDeposit() {
        setReturnValue("e2bbb158ea830e9efa91fa2a38c9708f9f6109a6c571d6a762b53a83776a3d67")
        val expected = "0xe2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb"
        val actual = CultDao.deposit(
            BigInt.from(0),
            BigInt.from("87348030907832289007691499")
        )
        assertEquals(expected, actual)
    }
}