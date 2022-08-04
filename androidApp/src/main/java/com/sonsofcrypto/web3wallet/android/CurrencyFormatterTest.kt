package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.formatters.CurrencyFormatter
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.BigInt

class CurrencyFormatterTest {

    fun runAll() {
        testFormatting()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testFormatting() {
        val values = listOf(
            BigInt.from("22871840522051356", 10),
//            BigInt.from("2822183128054209252826144", 10)
        )

        val formatter = CurrencyFormatter()
        values.forEach {
            val formatted = formatter.format(it, currency = Currency.ethereum())
            println("=== $formatted")
        }

    }
}