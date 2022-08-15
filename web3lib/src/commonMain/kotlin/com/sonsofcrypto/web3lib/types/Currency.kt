package com.sonsofcrypto.web3lib.types

import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.Serializable

@Serializable
data class Currency(
    val name: String,
    val symbol: String,
    val decimals: UInt?,
    val type: Type,
    val address: AddressHexString?,
    val coinGeckoId: String?,
) {
    @Serializable
    enum class Type(val value: Int) {
        UNKNOWN(0), NATIVE(1), ERC20(2)
    }

    fun id(): String {
        coinGeckoId?.let { return coinGeckoId + (address ?: "") }
        return (symbol + (address ?: name))
    }

    fun decimals(): UInt = this.decimals ?: 18u

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
