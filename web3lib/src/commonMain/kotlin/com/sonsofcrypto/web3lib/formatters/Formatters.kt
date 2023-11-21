package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt

class Formatters {

    companion object {
        val currency = CurrencyFormatter()
        val fiat = FiatFormatter()
        val pct = PctFormatter()
        val date = DateFormatter()
        val address = NetworkAddressFormatter()

        fun crypto(amount: BigInt, decimals: UInt, mul: Double): Double {
            return BigDec.from(amount)
                .div(BigDec.from(BigInt.from(10).pow(decimals.toLong())))
                .mul(BigDec.from(mul))
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