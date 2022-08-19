package com.sonsofcrypto.web3lib.types

import kotlinx.serialization.SerialName
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
        @SerialName("0") UNKNOWN(0),
        @SerialName("1") NATIVE(1),
        @SerialName("2") ERC20(2),
    }

    fun id(): String {
        coinGeckoId?.let { return coinGeckoId }
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
        fun cult(): Currency = Currency(
            name = "Cult DAO",
            symbol = "cult",
            decimals = 18u,
            type = Type.ERC20,
            address = null,
            coinGeckoId = "cult-dao",
        )
    }
}
