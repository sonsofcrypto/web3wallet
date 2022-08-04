package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt

class CurrencyFormatter {

    fun format(bigInt: BigInt?, currency: Currency): String {
        if (bigInt == null) {
            return "0"
        }
        val dec = BigDec.from(bigInt).div(BigDec.from(currency.decimals))
        return dec.toDecimalString()
    }

    fun bigInt(string: String, currency: Currency): BigInt {
        return BigDec.from(string, 10)
            .mul(BigDec.from(currency.decimals))
            .toBigInt()
    }
}