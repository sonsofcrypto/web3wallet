package com.sonsofcrypto.web3lib.services.keyStore.CurrencyMetadata

import com.sonsofcrypto.web3lib.services.coinGecko.CoinGeckoService
import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
import com.sonsofcrypto.web3lib.services.coinGecko.model.Market
import com.sonsofcrypto.web3lib.services.currencies.CurrenciesInfoStore
import com.sonsofcrypto.web3lib.services.currencyMetadata.BundledAssetProvider
import com.sonsofcrypto.web3lib.types.Currency
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.Instant

typealias HexColor = String
typealias ImageBytes = ByteArray

interface CurrencyMetadataService {

    fun cachedImage(currency: Currency?): ByteArray?
    fun cachedCandles(currency: Currency?): List<Candle>?
    fun market(currency: Currency?): Market?
    fun colors(currency: Currency?): Pair<HexColor, HexColor>

    suspend fun image(currency: Currency): ByteArray?
    suspend fun refreshMarket(currencies: List<Currency>): Map<String, Market>
    suspend fun candles(currency: Currency): List<Candle>
}

class DefaultCurrencyMetadataService: CurrencyMetadataService {

    private var candleCache: MutableMap<String, List<Candle>> = mutableMapOf()
    private var candleUpdate: MutableMap<String, Instant> = mutableMapOf()

    private var market: MutableMap<String, Market> = mutableMapOf()
    private var marketUpdate: MutableMap<String, Instant> = mutableMapOf()

    private val bundledAssetProvider: BundledAssetProvider
    private val coinGeckoService: CoinGeckoService
    private val currenciesInfoStore: CurrenciesInfoStore

    constructor(
        bundledAssetProvider: BundledAssetProvider,
        coinGeckoService: CoinGeckoService,
        currenciesInfoStore: CurrenciesInfoStore,
    ) {
        this.bundledAssetProvider = bundledAssetProvider
        this.coinGeckoService = coinGeckoService
        this.currenciesInfoStore = currenciesInfoStore
    }

    override fun cachedImage(currency: Currency?): ByteArray? {
        if (currency == null) {
            return null
        }

        (currency?.coinGeckoId ?: currency?.symbol)?.let { id ->
            bundledAssetProvider.image(id)?.let {
                return it
            }
        }

        // TODO: Check cache
        return null
    }

    override fun cachedCandles(currency: Currency?): List<Candle>? {
        return if (currency != null) candleCache[currency.id()] else null
    }

    override fun market(currency: Currency?): Market? {
        return if (currency != null) market[currency.id()] else null
    }

    override fun colors(currency: Currency?): Pair<HexColor, HexColor> {
        if (currency != null) {
            currenciesInfoStore.info(currency)?.colors?.let { colors ->
                return when {
                    colors.size > 1 -> Pair(colors[0], colors[1])
                    colors.size == 1 -> Pair(colors[0], colors[0])
                    else -> Pair("0xffffff", "0xffffff")
                }
            }
        }
        return Pair("0xffffff", "0xffffff")
    }

    override suspend fun image(currency: Currency): ByteArray? {
        // TODO: Download from network
        val id = (currency.coinGeckoId ?: currency.symbol) + "_large"
        return bundledAssetProvider.image(id)
    }

    override suspend fun refreshMarket(currencies: List<Currency>): Map<String, Market> {
        var markets = withContext(Dispatchers.Default) {
            return@withContext coinGeckoService.market(
                currencies.map { it.coinGeckoId }.filterNotNull(),
                "usd",
                page = 1,
                "24h"
            )
        }

        val result: MutableMap<String, Market> = mutableMapOf()

        for (market in markets) {
            currencies.find { it.coinGeckoId == market.id }?.let {
                result.put(it.id(), market)
            }
        }

        this.market = result
        return result
    }

    override suspend fun candles(currency: Currency): List<Candle> {
        currency.coinGeckoId?.let {
            val result = coinGeckoService.candles(it, "usd", 30)
            candleCache.put(currency.id(), result)
            return result
        }
        return listOf()
    }
}
