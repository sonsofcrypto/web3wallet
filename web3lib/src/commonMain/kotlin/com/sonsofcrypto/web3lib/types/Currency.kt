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

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Currency) return false
        if (type != other.type) return false
        return address == other.address
    }

    fun decimals(): UInt = this.decimals ?: 18u

    val iconName: String get() = coinGeckoId ?: "currency_placeholder"

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
            address = "0xf0f9d895aca5c8678f706fb8216fa22957685a13",
            coinGeckoId = "cult-dao",
        )
        fun usdt(): Currency = Currency(
            name = "Tether Usd",
            symbol = "usdt",
            decimals = 6u,
            type = Type.ERC20,
            address = "0xdac17f958d2ee523a2206206994597c13d831ec7",
            coinGeckoId = "cult-dao",
        )
        fun dai(): Currency = Currency(
            name = "DAI",
            symbol = "DAI",
            decimals = 18u,
            type = Type.ERC20,
            address = "0x6b175474e89094c44da98b954eedeac495271d0f",
            coinGeckoId = "DAI",
        )
    }
}
