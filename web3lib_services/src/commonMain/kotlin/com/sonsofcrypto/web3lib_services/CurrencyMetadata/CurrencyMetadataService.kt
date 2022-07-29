package com.sonsofcrypto.web3lib_services.CurrencyMetadata

import com.sonsofcrypto.web3lib_core.Currency
import com.sonsofcrypto.web3lib_services.GoinGecko.CoinGeckoService
import com.sonsofcrypto.web3lib_services.GoinGecko.model.Candle
import com.sonsofcrypto.web3lib_services.GoinGecko.model.Market
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.Instant

typealias HexColor = String
typealias ImageBytes = ByteArray

interface CurrencyMetadataService {

    fun cachedImage(currency: Currency): ByteArray?
    fun cachedCandles(currency: Currency): List<Candle>?
    fun market(currency: Currency): Market?
    fun colors(currency: Currency): Pair<HexColor, HexColor>

    suspend fun image(currency: Currency): ByteArray?
    suspend fun refreshMarket(currencies: List<Currency>): Map<Currency, Market>
    suspend fun candles(currency: Currency): List<Candle>
}

class DefaultCurrencyMetadataService: CurrencyMetadataService {

    private var candleCache: MutableMap<Currency, List<Candle>> = mutableMapOf()
    private var candleUpdate: MutableMap<Currency, Instant> = mutableMapOf()

    private var market: MutableMap<Currency, Market> = mutableMapOf()
    private var marketUpdate: MutableMap<Currency, Instant> = mutableMapOf()

    private val bundledImageProvider: BundledImageProvider
    private val coinGeckoService: CoinGeckoService

    constructor(
        bundledImageProvider: BundledImageProvider,
        coinGeckoService: CoinGeckoService,
    ) {
        this.bundledImageProvider = bundledImageProvider
        this.coinGeckoService = coinGeckoService
    }

    override fun cachedImage(currency: Currency): ByteArray? {
        val id = (currency?.coinGeckoId ?: currency.symbol) + "_large"
        bundledImageProvider.image(id)?.let {
            return it
        }

        // TODO: Check cache
        return null
    }

    override fun cachedCandles(currency: Currency): List<Candle>? {
        return candleCache[currency]
    }

    override fun market(currency: Currency): Market? {
        return market[currency]
    }

    override fun colors(currency: Currency): Pair<HexColor, HexColor> {
        return Pair("0xffffff", "0xffffff")
    }

    override suspend fun image(currency: Currency): ByteArray? {
        // TODO: Download from network
        val id = (currency?.coinGeckoId ?: currency.symbol) + "_large"
        return bundledImageProvider.image(id)
    }

    override suspend fun refreshMarket(currencies: List<Currency>): Map<Currency, Market> {
        var markets = withContext(Dispatchers.Default) {
            return@withContext coinGeckoService.market(
                (currencies ?: listOf())
                    .map { it.coinGeckoId }
                    .filterNotNull(),
                "usd",
                page = 1,
                "24h"
            )
        }

        val result: MutableMap<Currency, Market> = mutableMapOf()

        for (market in markets) {
            currencies.find { it.coinGeckoId == market.id }?.let {
                result.put(it, market)
            }
        }

        this.market = result
        return result
    }

    override suspend fun candles(currency: Currency): List<Candle> {
        currency.coinGeckoId?.let {
            val result = coinGeckoService.candles(it, "usd", 30)
            candleCache.put(currency, result)
            return result
        }
        return listOf()
    }
}
