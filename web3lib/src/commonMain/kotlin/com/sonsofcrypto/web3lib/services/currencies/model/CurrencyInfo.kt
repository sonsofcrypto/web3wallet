package com.sonsofcrypto.web3lib.services.currencies.model

import com.sonsofcrypto.web3lib.services.coinGecko.model.Coin
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlinx.serialization.Serializable

@Serializable
data class CurrencyInfo(
    val id: String,
    val symbol: String,
    val name: String,
    val platforms: Platforms?,
    val imageURL: String?,
    val rank: Long?,
) {

    @Serializable
    data class Platforms(
        val ethereum: String?
    ) {
        companion object {

            fun from(platforms: Coin.Platforms?): Platforms? {
                return if (platforms != null) {
                    return Platforms(platforms.ethereum)
                } else null
            }
        }
    }

    class CompareStoreCoin {

        companion object : Comparator<CurrencyInfo> {
            override fun compare(a: CurrencyInfo, b: CurrencyInfo): Int {
                val aRank = a.rank ?: Long.MAX_VALUE
                val bRank = b.rank ?: Long.MAX_VALUE
                if (aRank < bRank) return -1
                if (aRank > bRank) return 1
                return 0
            }
        }
    }
}

fun CurrencyInfo.Companion.listFrom(data: String): List<CurrencyInfo> {
    val currencyInfoJson = Json {
        encodeDefaults = true
        isLenient = true
        ignoreUnknownKeys = true
        coerceInputValues = true
        allowStructuredMapKeys = true
        useAlternativeNames = false
        prettyPrint = true
        useArrayPolymorphism = true
        explicitNulls = false
    }
    return currencyInfoJson.decodeFromString(data)
}