package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt

class Formatters {

    companion object {
        val currency = CurrencyFormatter()
        val fiat = FiatFormatter()
        val pct = PctFormatter()
        val date = DateFormatter()
        val networkAddress = NetworkAddressFormatter()

        fun crypto(amount: BigInt, decimals: UInt, mul: Double): Double {
            // Once we calculate the crypto amount, since the result will be in FIAT we are only
            // interested in 2 decimal places precision.
            return BigDec.from(amount)
                .div(BigDec.from(BigInt.from(10).pow(decimals.toLong())))
                .mul(BigDec.from(mul))
                .mul(BigDec.from(100))
                .toBigInt()
                .toBigDec()
                .div(BigDec.from(100))
                .toDouble()
        }
    }

    sealed class Style {
        data class Custom(val maxLength: UInt): Style()
        object Max: Style()
    }

    sealed class Output {
        data class Up(val value: String): Output()
        data class Normal(val value: String): Output()
        data class Down(val value: String): Output()
    }
}