package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt

class CurrencyFormatter {

    fun format(bigInt: BigInt?, currency: Currency): String {
        if (bigInt == null) {
            return "0"
        }
        val divisor = BigInt.from(10).pow(currency.decimals().toLong())
        val dec = BigDec.from(bigInt).div(BigDec.from(divisor))
        return dec.toDouble().toString()
    }

    fun bigInt(string: String, currency: Currency): BigInt {
        return BigDec.from(string, 10)
            .mul(BigDec.from(currency.decimals()))
            .toBigInt()
    }

    companion object {

        fun crypto(amount: BigInt, decimals: UInt, mul: Double): Double {
            return BigDec.from(amount)
                .div(BigDec.from(BigInt.from(10).pow(decimals.toLong())))
                .mul(BigDec.from(mul))
                .toDouble()
        }
    }
}