package com.sonsofcrypto.web3lib.services.currencyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.CoinGeckoService
import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
import com.sonsofcrypto.web3lib.services.coinGecko.model.toCurrencyMarketData
import com.sonsofcrypto.web3lib.utils.BundledAssetProvider
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.Trie
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.jsonEncode
import com.sonsofcrypto.web3lib.utils.extensions.subListTo
import com.sonsofcrypto.web3lib.utils.logExceptionHandler
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import io.ktor.util.*
import kotlinx.coroutines.*
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlin.native.concurrent.SharedImmutable

/** `CurrencyStoreService` handles currencies list and associated metadata. */
interface CurrencyStoreService {
    /** Cached metadata for currency */
    fun metadata(currency: Currency): CurrencyMetadata?
    /** Latest known (cached) market data for currency */
    fun marketData(currency: Currency): CurrencyMarketData?
    /** Latest known (cached) candles for currency */
    fun candles(currency: Currency): List<Candle>?

    /** Downloads and caches market data for currency */
    suspend fun fetchMarketData(currencies: List<Currency>): Map<String, CurrencyMarketData>?
    /** Downloads and caches candles for currency */
    suspend fun fetchCandles(currency: Currency): List<Candle>?

    /** Currencies for network order by rank. For all limit <= 0 */
    fun currencies(network: Network, limit: Int): List<Currency>
    /** Search currencies for network order by rank. For all limit <= 0 */
    fun search(term: String, network: Network, limit: Int): List<Currency>

    /** Restores all caches from previous session. Can take awhile */
    suspend fun loadCaches(networks: List<Network>): Job

    /** Add currency to store (custom user input currency) */
    fun add(currency: Currency, network: Network)
    /** remove custom currency from store */
    fun remove(currency: Currency, network: Network)

    /** Add listener for all events */
    fun add(listener: CurrencyStoreListener)
    /** Remove listener for all events, if null */
    fun remove(listener: CurrencyStoreListener?)
}

class DefaultCurrencyStoreService(
    private val coinGeckoService: CoinGeckoService,
    private val marketStore: KeyValueStore,
    private val candleStore: KeyValueStore,
    private val userCurrencyStore: KeyValueStore
): CurrencyStoreService {
    private var currencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private var metadatas: Map<String, CurrencyMetadata> = emptyMap()
    private var bundledMarkets: Map<String, CurrencyMarketData> = emptyMap()
    private var markets: MutableMap<String, CurrencyMarketData> = mutableMapOf()
    private var candles: MutableMap<String, List<Candle>> = mutableMapOf()
    private var listeners: MutableSet<CurrencyStoreListener> = mutableSetOf()
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)
    /** Temporary performance optimization, remove when switching to sqllite */
    private var tries: MutableMap<String, Trie> = mutableMapOf()
    private var idxMaps: MutableMap<String, Map<String, Int>> = mutableMapOf()

    override fun metadata(currency: Currency): CurrencyMetadata? {
        return metadatas.get(currency.coinGeckoId ?: currency.id())
    }

    override fun marketData(currency: Currency): CurrencyMarketData? {
        markets[currency.id()]?.let { return it }
        marketStore.get<String>(currency.id())?.let { return jsonDecode(it) }
        return bundledMarkets.get(currency.id())
    }

    override fun candles(currency: Currency): List<Candle>? {
        candles[currency.id()]?.let { return it }
        candleStore.get<String>(currency.id())?.let { return jsonDecode(it) }
        return null
    }

    override suspend fun fetchMarketData(
        currencies: List<Currency>): Map<String, CurrencyMarketData>? {
        return withContext(bgDispatcher + logExceptionHandler) {
            val ids = currencies.mapNotNull{ it.coinGeckoId }
            val resultMap = mutableMapOf<String, CurrencyMarketData>()
            coinGeckoService.market(ids, "usd", 0, "24h").forEach {
                resultMap.put(it.id, it.toCurrencyMarketData())
            }
            withContext(uiDispatcher) {
                resultMap.forEach {
                    markets.put(it.key, it.value)
                    marketStore.set(it.key, jsonEncode(it.value))
                }
                emit(CurrencyStoreEvent.MarketData)
            }
            return@withContext resultMap
        }
    }

    override suspend fun fetchCandles(currency: Currency): List<Candle>? {
        return withContext(bgDispatcher + logExceptionHandler) {
            val result = coinGeckoService.candles(currency.id(), "usd", 30)
            withContext(uiDispatcher) {
                candleStore.set(currency.id(), jsonEncode(result))
                candles.set(currency.id(), result)
                emit(CurrencyStoreEvent.Candles(result, currency))
            }
            return@withContext result
        }
    }

    override fun currencies(network: Network, limit: Int): List<Currency> {
        return if (limit <= 0) currencies[network.id()] ?: emptyList()
        else currencies[network.id()]?.subListTo(limit) ?: emptyList()
    }

    override fun search(term: String, network: Network, limit: Int): List<Currency> {
        val idxMap = idxMaps[network.id()]
        val currencies = currencies[network.id()]
        val words = tries[network.id()]?.wordsStartingWith(
            term.toLowerCasePreservingASCIIRules()
        ) ?: emptyList()
        return (if (limit <= 0) words else words.subListTo(limit))
            .mapNotNull { idxMap?.get(it) }
            .toSet()
            .mapNotNull { currencies?.get(it) }
    }

    override suspend fun loadCaches(networks: List<Network>) = scope.launch {
        val metadata = async { loadMetadataCaches() }
        val markets = async { loadMarketCaches() }
        handlesCacheResults(
            networks.map { async { loadCurrencyCaches(it) } }.awaitAll(),
            metadata.await(),
            markets.await(),
        )
    }

    override fun add(currency: Currency, network: Network) {
        currencies.put(network.id(), currencies(network, 0) + listOf(currency))
        userCurrencyStore.set(
            network.id(),
            jsonEncode(userCurrencies(network) + listOf(currency))
        )
    }

    override fun remove(currency: Currency, network: Network) {
        userCurrencyStore.set(
            network.id(),
            userCurrencies(network).filter { it.id() != currency.id() }
        )
        currencies.put(
            network.id(),
            currencies(network, 0).filter { it.id() != currency.id() }
        )
    }

    private fun userCurrencies(network: Network): List<Currency> {
        val str = userCurrencyStore.get<String>(network.id()) ?: "[]"
        return jsonDecode(str) ?: listOf()
    }

    override fun add(listener: CurrencyStoreListener) {
        listeners.add(listener)
    }

    private fun emit(event: CurrencyStoreEvent) {
        listeners.forEach { it.handle(event) }
    }

    override fun remove(listener: CurrencyStoreListener?) {
        listeners.remove(listener)
    }

    private suspend fun loadCurrencyCaches(
        network: Network
    ): CurrencyCache = withContext(bgDispatcher) {
        val name = "cache_currencies_${network.chainId}"
        val data = BundledAssetProvider().file(name, "json")
        val jsonString = data?.decodeToString() ?: "[]"
        val currencies = jsonDecode<List<Currency>>(jsonString) ?: emptyList()
        val trie = Trie()
        val idxMap = mutableMapOf<String, Int>()
        (currencies + userCurrencies(network)).forEachIndexed { idx, currency ->
            val name = currency.name.toLowerCasePreservingASCIIRules()
            val symbol = currency.symbol.toLowerCasePreservingASCIIRules()
            trie.insert(name)
            trie.insert(symbol)
            idxMap.put(name, idx)
            idxMap.put(symbol, idx)
        }
        return@withContext CurrencyCache(network, currencies, trie, idxMap)
    }

    private suspend fun loadMetadataCaches(): Map<String, CurrencyMetadata> =
        withContext(bgDispatcher) {
            jsonDecode(file("cache_metadatas") ?: "{}") ?: emptyMap()
        }

    private suspend fun loadMarketCaches(): Map<String, CurrencyMarketData> =
        withContext(bgDispatcher) {
            jsonDecode(file("cache_markets") ?: "{}") ?: emptyMap()
        }

    private suspend fun handlesCacheResults(
        currencyCache: List<CurrencyCache>,
        metadataCache: Map<String, CurrencyMetadata>,
        marketDataCache: Map<String, CurrencyMarketData>,
    ) = withContext(uiDispatcher) {
        metadatas = metadataCache
        bundledMarkets = marketDataCache
        currencyCache.forEach {
            currencies.put(it.network.id(), it.currencies)
            tries.put(it.network.id(), it.trie)
            idxMaps.put(it.network.id(), it.idxMap)
        }
        emit(CurrencyStoreEvent.CacheLoaded)
    }

    private data class CurrencyCache(
        val network: Network,
        val currencies: List<Currency>,
        val trie: Trie,
        val idxMap: Map<String, Int>,
    )

    private fun file(name: String): String? {
        return BundledAssetProvider().file(name, "json")?.decodeToString()
    }
}