package com.sonsofcrypto.web3lib_core

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
