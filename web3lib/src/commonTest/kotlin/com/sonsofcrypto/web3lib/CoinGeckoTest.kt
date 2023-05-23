package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.provider.providerJson
import com.sonsofcrypto.web3lib.services.coinGecko.model.Market
import com.sonsofcrypto.web3lib.utils.FileManager
import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.logging.SIMPLE
import io.ktor.client.request.get
import io.ktor.client.statement.bodyAsText
import io.ktor.client.utils.EmptyContent.contentType
import io.ktor.http.ContentType
import io.ktor.http.withCharset
import io.ktor.serialization.kotlinx.json.json
import io.ktor.utils.io.charsets.Charsets
import io.ktor.utils.io.core.String
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import okio.FileSystem
import kotlin.native.concurrent.SharedImmutable
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import com.sonsofcrypto.web3lib.BuildKonfig
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import kotlinx.serialization.Serializable
import kotlin.test.assertTrue
import kotlin.time.ExperimentalTime


private val testJson = Json {
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

class CoinGeckoTest() {

    @Test
    fun testCoinsList() = runBlocking {
        val coinGeckoService = DefaultCoinGeckoService()
        val coins = coinGeckoService.coinsList()
        assertTrue(
            coins.count() > 10000,
            "Coin Gecko expects ~10k count, got: ${coins.count()}"
        )
        assertTrue(
            coins.firstOrNull() != null,
            "First coin was null"
        )
    }

    @Test
    fun testMarket() = runBlocking {
        val coinGeckoService = DefaultCoinGeckoService()
        val markets = coinGeckoService.market(
            ids = null,
            quote = "usd",
            page = 0,
            change = "24h",
        )
        assertTrue(
            markets.count() >= 250,
            "Expected at least 250 markets, got ${markets.count()}"
        )
        assertTrue(
            markets.first().id == "bitcoin",
            "First market expected to be Bitcoin ${markets.first().id}"
        )
    }

    @Test
    fun testCandles() = runBlocking {
        val coinGeckoService = DefaultCoinGeckoService()
        val candles = coinGeckoService.candles(
            coinId = "ethereum",
            quote = "usd",
            days = 30,
        )
        println("=== Candles count ${candles.count()}")
        println("=== Candles ${candles.firstOrNull()}")
        assertTrue(
            candles.count() > 30,
            "Expected at least 30 candles, got ${candles.count()}"
        )
        assertTrue(
            candles.firstOrNull() != null && candles.first()?.high != null,
            "First candle has null value ${candles.first()}"
        )
    }

    @OptIn(ExperimentalTime::class)
    @Test
    fun constructCoinData() = runBlocking {
        val coinGeckoService = DefaultCoinGeckoService()
        val coins = coinGeckoService.coinsList()
        val fileCoins = File(context.getFilesDir(), "coins.json")
        fileCoins.writeText(testJson.encodeToString(coins))
        println("=== dowloaded ${coins.count()} coins, ${fileCoins.path}")

        var markets = mutableListOf<Market>()
        for (i in 1..53) {
            delay(2.seconds)
            println("=== starting $i")
            val marketsPage = coinGeckoService.market(
                ids = null,
                quote = "usd",
                page = i,
                change = "24h",
            )
            markets.addAll(marketsPage)
        }

        val fileMarkets = File(context.getFilesDir(), "markets.json")
        fileMarkets.writeText(testJson.encodeToString(markets))
        println("=== dowloaded ${markets.count()} markets, ${fileMarkets.path}")

        var storeCoins = mutableListOf<StoreCoin>()
        for (coin in coins) {
            val market = markets.find { it.id == coin.id }
            val storeCoin = StoreCoin(
                id = coin.id,
                symbol = coin.symbol,
                name = coin.name,
                platforms = StoreCoin.Platforms.from(coin.platforms),
                imageURL = market?.image,
                rank = market?.marketCapRank,
            )
            storeCoins.add(storeCoin)
        }

        storeCoins.sortWith(StoreCoin.CompareStoreCoin)

        val fileStoreCoin = File(context.getFilesDir(), "storeCoins.json")
        fileStoreCoin.writeText(testJson.encodeToString(storeCoins))
        println("=== processed ${storeCoins.count()} coins, ${fileStoreCoin.path}")

        val filteredCoins = storeCoins.filter { it.platforms?.ethereum != null }
        val fileFilteredCoins = File(context.getFilesDir(), "filteredCoins.json")
        fileFilteredCoins.writeText(testJson.encodeToString(filteredCoins))
        println("=== filtered ${filteredCoins.count()} coins, ${fileFilteredCoins.path}")

        // Download image for top thousands
    }

}

@Serializable
data class StoreCoin(
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

            fun from(platforms: Platforms?): Platforms? {
                return if (platforms != null) {
                    return Platforms(platforms.ethereum)
                } else null
            }
        }
    }

    class CompareStoreCoin {

        companion object : Comparator<StoreCoin> {
            override fun compare(a: StoreCoin, b: StoreCoin): Int {
                val aRank = a.rank ?: Long.MAX_VALUE
                val bRank = b.rank ?: Long.MAX_VALUE
                if (aRank < bRank) return -1
                if (aRank > bRank) return 1
                return 0
            }
        }
    }
}