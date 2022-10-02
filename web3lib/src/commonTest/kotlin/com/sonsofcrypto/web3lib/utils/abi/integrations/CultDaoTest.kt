package com.sonsofcrypto.web3lib.utils.abi.integrations

import com.sonsofcrypto.web3lib.utils.BigInt
import kotlin.test.Test
import kotlin.test.assertEquals

class CultDaoTest {
    @Test
    fun testCultDaoDeposit() {
        val expected = "0xe2bbb15800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004840aa3e5e8b722426e6eb"
        val actual = CultDao.deposit(
            BigInt.from(0),
            BigInt.from("87348030907832289007691499")
        )
        assertEquals(expected, actual)
    }
}