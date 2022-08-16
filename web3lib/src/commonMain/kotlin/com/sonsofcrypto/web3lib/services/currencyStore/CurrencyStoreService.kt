package com.sonsofcrypto.web3lib.services.currencyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
import com.sonsofcrypto.web3lib.services.currencyMetadata.BundledAssetProvider
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.Trie
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.subListTo
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import io.ktor.util.*
import kotlinx.coroutines.*
import kotlinx.serialization.decodeFromString
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
    suspend fun fetchMarketData(currencies: List<Currency>): CurrencyMarketData?
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
class DefaultCurrencyStoreService: CurrencyStoreService {
    private var currencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private var userCurrencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private var metadatas: Map<String, CurrencyMetadata> = emptyMap()
    private var bundledMarkets: Map<String, CurrencyMarketData> = emptyMap()
    private var markets: Map<String, CurrencyMarketData> = emptyMap()
    private var candles: MutableMap<String, List<Candle>> = mutableMapOf()
    private var listeners: MutableSet<CurrencyStoreListener> = mutableSetOf()
    private var marketsStore = KeyValueStore("CurrencyStoreService.Markets")
    private var candleStore = KeyValueStore("CurrencyStoreService.Candles")
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)
    /** Temporary performance optimization, remove when switching to sqllite */
    private var tries: MutableMap<String, Trie> = mutableMapOf()
    private var idxMaps: MutableMap<String, Map<String, Int>> = mutableMapOf()

    override fun metadata(currency: Currency): CurrencyMetadata? {
        return metadatas.get(currency.coinGeckoId ?: currency.id())
    }

    override fun marketData(currency: Currency): CurrencyMarketData? {
        val id = currency.id()
        return markets[id]
            ?: marketsStore.get<String>(id)?.let { return jsonDecode(it) }
            ?: bundledMarkets.get(id)
    }

    override fun candles(currency: Currency): List<Candle>? {
        val id = currency.id()
        return candles[id]
            ?: candleStore.get<String>(id)?.let { return jsonDecode(it) }
    }

    override suspend fun fetchMarketData(currencies: List<Currency>): CurrencyMarketData? {
        TODO("Not yet implemented")
    }

    override suspend fun fetchCandles(currency: Currency): List<Candle>? {
        TODO("Not yet implemented")
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
        TODO("Not yet implemented")
    }

    override fun remove(currency: Currency, network: Network) {
        TODO("Not yet implemented")
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
        val currencies = csJson.decodeFromString<List<Currency>>(jsonString)
        val trie = Trie()
        val idxMap = mutableMapOf<String, Int>()
        currencies.forEachIndexed { idx, currency ->
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
            csJson.decodeFromString(file("cache_metadatas") ?: "{}")
        }

    private suspend fun loadMarketCaches(): Map<String, CurrencyMarketData> =
        withContext(bgDispatcher) {
            csJson.decodeFromString(file("cache_markets") ?: "{}")
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

@SharedImmutable
private val csJson = Json {
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
