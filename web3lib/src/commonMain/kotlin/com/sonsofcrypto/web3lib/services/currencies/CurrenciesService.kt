package com.sonsofcrypto.web3lib.services.currencies

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.currencies.model.CurrencyInfo
import com.sonsofcrypto.web3lib.services.currencies.model.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.currencies.model.listFrom
import com.sonsofcrypto.web3lib.services.currencies.model.ropstenDefaultCurrencies
import com.sonsofcrypto.web3lib.services.currencyMetadata.BundledAssetProvider
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.Trie
import com.sonsofcrypto.web3lib.utils.defaultDispatcher
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import io.ktor.util.*
import kotlinx.coroutines.*
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlin.native.concurrent.SharedImmutable
import kotlin.time.Duration
import kotlin.time.ExperimentalTime

interface CurrenciesService {
    fun currencies(wallet: Wallet, network: Network): List<Currency>
    fun add(currency: Currency, wallet: Wallet, network: Network)
    fun remove(currency: Currency, wallet: Wallet, network: Network)

    fun generateDefaultCurrenciesIfNeeded(wallet: Wallet, network: Network)
    fun defaultCurrencies(network: Network): List<Currency>

    var currencies: List<Currency>
    fun currencies(search: String): List<Currency>

    suspend fun loadCurrencies()
}

@OptIn(ExperimentalTime::class)
class DefaultCurrenciesService(val store: KeyValueStore): CurrenciesService {

    override var currencies: List<Currency> = listOf()

    private var namesTrie: Trie = Trie()
    private var symbolsTrie: Trie = Trie()
    private var namesMap: Map<String, Int> = emptyMap()
    private var symbolsMap: Map<String, Int> = emptyMap()
    private val scope = CoroutineScope(SupervisorJob() + defaultDispatcher)

    init {
        val handler = CoroutineExceptionHandler { _, exception ->
            println("CoroutineExceptionHandler: $exception")
        }
        scope.launch(handler) {
            loadCurrencies()
        }
    }

    override fun currencies(wallet: Wallet, network: Network): List<Currency> {
        return getCurrencies(id(wallet, network)) ?: listOf()
    }

    override fun add(currency: Currency, wallet: Wallet, network: Network) {
        setCurrencies(
            id(wallet, network),
            currencies(wallet, network) + listOf(currency)
        )
    }

    override fun remove(currency: Currency, wallet: Wallet, network: Network) {
        setCurrencies(
            id(wallet, network),
            currencies(wallet, network).filter { it != currency }
        )
    }

    override fun generateDefaultCurrenciesIfNeeded(wallet: Wallet, network: Network) {
        if (currencies(wallet, network).isEmpty()) {
            setCurrencies(id(wallet, network), defaultCurrencies(network))
        }
    }

    override fun defaultCurrencies(network: Network): List<Currency> {
        return when(network) {
            Network.ethereum() -> ethereumDefaultCurrencies
            Network.ropsten() -> ropstenDefaultCurrencies
            else -> listOf()
        }
    }

    override fun currencies(search: String): List<Currency> {
        if (search.isEmpty()) {
            return emptyList()
        }
        val results = mutableSetOf<Currency>()
        val searchTerm = search.toLowerCasePreservingASCIIRules()
        namesTrie.wordsStartingWith(searchTerm).forEach {
            namesMap[it]?.let { idx -> results.add(currencies[idx]) }
        }
        symbolsTrie.wordsStartingWith(searchTerm).forEach {
            symbolsMap[it]?.let { idx -> results.add(currencies[idx]) }
        }
        return results.toList()
    }

    override suspend fun loadCurrencies() = withContext(defaultDispatcher) {
        val singleThreadContext = newSingleThreadContext("coin_cache_loading")
        withContext(singleThreadContext) {
            val data = BundledAssetProvider().file("coin_cache", "json")
            val jsonString = data?.decodeToString() ?: "[]"
            val currencies = CurrencyInfo.listFrom(jsonString).map {
                Currency(
                    name = it.name,
                    symbol = it.symbol,
                    decimals = 18u,
                    type = if(it.platforms?.ethereum != null) Currency.Type.ERC20
                    else Currency.Type.NATIVE,
                    address = it.platforms?.ethereum,
                    coinGeckoId = it.id,
                )
            }
            val namesTrie = Trie()
            val symbolsTrie = Trie()
            val namesMap = mutableMapOf<String, Int>()
            val symbolsMap = mutableMapOf<String, Int>()
            currencies.forEachIndexed { idx, currency ->
                val name = currency.name.toLowerCasePreservingASCIIRules()
                val symbol = currency.symbol.toLowerCasePreservingASCIIRules()
                namesTrie.insert(name)
                namesMap.put(name, idx)
                symbolsTrie.insert(symbol)
                symbolsMap.put(symbol, idx)
            }
            withContext(uiDispatcher) {
                updateCurrencies(
                    currencies,
                    namesTrie,
                    symbolsTrie,
                    namesMap,
                    symbolsMap
                )
            }
        }
    }

    private fun updateCurrencies(
        currencies: List<Currency>,
        namesTrie: Trie,
        symbolsTrie: Trie,
        namesMap: Map<String, Int>,
        symbolsMap: Map<String, Int>,
    ) {
        this.currencies = currencies
        this.namesTrie = namesTrie
        this.symbolsTrie = symbolsTrie
        this.namesMap = namesMap
        this.symbolsMap = symbolsMap
    }

    private fun setCurrencies(key: String, currencies: List<Currency>) {
        store[key] = currenciesJson.encodeToString(currencies)
    }

    private fun getCurrencies(key: String): List<Currency>? {
        return store.get<String>(key)?.let {
            return currenciesJson.decodeFromString<List<Currency>>(it)
        }
    }

    private fun id(wallet: Wallet, network: Network): String {
        return wallet.id() + "-" + network.id()
    }
}

@SharedImmutable @OptIn(kotlinx.serialization.ExperimentalSerializationApi::class)
private val currenciesJson = Json {
    encodeDefaults = true
    isLenient = true
    ignoreUnknownKeys = true
    coerceInputValues = true
    allowStructuredMapKeys = true
    useAlternativeNames = false
    prettyPrint = false
    useArrayPolymorphism = true
    explicitNulls = true
}