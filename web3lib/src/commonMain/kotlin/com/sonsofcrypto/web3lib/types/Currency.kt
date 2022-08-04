package com.sonsofcrypto.web3lib.types

import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.Serializable

@Serializable
data class Currency(
    val name: String,
    val symbol: String,
    val decimals: UInt,
    val type: Type,
    val address: AddressHexString?,
    val coinGeckoId: String?
) {
    enum class Type() {
        NATIVE, ERC20, UNKNOWN
    }

    fun id(): String {
        return coinGeckoId ?: (symbol + (address ?: name))
    }

    fun double(balance: BigInt): Double {
        if (balance == null) {
            return 0.0
        }
        val divisor = BigInt.from(10).pow(decimals.toLong())
        return BigDec.from(balance).div(BigDec.from(divisor)).toDouble()
    }

    companion object {
        fun ethereum(): Currency = Currency(
            name = "Ethereum",
            symbol = "eth",
            decimals = 18u,
            type = Type.NATIVE,
            address = null,
            coinGeckoId = "ethereum",
        )
    }
}
