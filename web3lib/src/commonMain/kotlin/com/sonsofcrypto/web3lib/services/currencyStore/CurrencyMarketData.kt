package com.sonsofcrypto.web3lib.services.currencyStore

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CurrencyMarketData(
    @SerialName("current_price")
    val currentPrice: Double?,
    @SerialName("market_cap")
    val marketCap: Double?,
    @SerialName("market_cap_rank")
    val marketCapRank: Long?,
    @SerialName("fully_diluted_valuation")
    val fullyDilutedValuation: Double?,
    @SerialName("total_volume")
    val totalVolume: Double?,
    @SerialName("price_change_percentage_24h")
    val priceChangePercentage24h: Double?,
    @SerialName("circulating_supply")
    val circulatingSupply: Double?,
    @SerialName("total_supply")
    val totalSupply: Double?,
)
