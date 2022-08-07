package com.sonsofcrypto.web3lib.services.currencies

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.currencies.model.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.currencies.model.ropstenDefaultCurrencies
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlin.native.concurrent.SharedImmutable
import kotlin.time.ExperimentalTime

interface CurrenciesService {
    fun currencies(wallet: Wallet): List<Currency>
    fun add(currency: Currency, wallet: Wallet)
    fun remove(currency: Currency, wallet: Wallet)

    /** Replaces currency list of existing currencies (ie remove existing) */
    fun setSelected(currencies: List<Currency>, wallet: Wallet)

    fun generateDefaultCurrenciesIfNeeded(wallet: Wallet)
    fun defaultCurrencies(network: Network): List<Currency>

    var currencies: List<Currency>
    fun currencies(search: String): List<Currency>

    suspend fun loadCurrencies()
}

@OptIn(ExperimentalTime::class)
class DefaultCurrenciesService(
        val store: KeyValueStore,
        val currenciesStore: CurrenciesInfoStore,
    ): CurrenciesService {

    override var currencies: List<Currency>
        get() { return currenciesStore.currencies }
        set(value) {}

    private var selectedCurrencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)

    init {
        val handler = CoroutineExceptionHandler { _, exception ->
            println("CoroutineExceptionHandler: $exception")
        }
        scope.launch(handler) {
            loadCurrencies()
        }
    }

    override fun currencies(wallet: Wallet): List<Currency> {
        return getCurrencies(id(wallet)) ?: listOf()
    }

    override fun add(currency: Currency, wallet: Wallet) {
        setCurrencies(
            id(wallet),
            currencies(wallet) + listOf(currency)
        )
    }

    override fun remove(currency: Currency, wallet: Wallet) {
        setCurrencies(id(wallet), currencies(wallet).filter { it != currency })
    }

    override fun setSelected(currencies: List<Currency>, wallet: Wallet) {
        setCurrencies(id(wallet), currencies)
    }

    override fun generateDefaultCurrenciesIfNeeded(wallet: Wallet) {
        if (currencies(wallet).isEmpty()) {
            val network = wallet.network() ?: Network.ethereum()
            setCurrencies(id(wallet), defaultCurrencies(network))
        }
    }

    override fun currencies(search: String): List<Currency> {
        return currenciesStore.currencies(search)
    }

    override suspend fun loadCurrencies() {
        currenciesStore.loadCurrencies()
    }

    override fun defaultCurrencies(network: Network): List<Currency> {
        return when(network) {
            Network.ethereum() -> ethereumDefaultCurrencies
            Network.ropsten() -> ropstenDefaultCurrencies
            else -> listOf()
        }
    }

    private fun setCurrencies(key: String, currencies: List<Currency>) {
        selectedCurrencies.put(key, currencies)
        store[key] = currenciesJson.encodeToString(currencies)
    }

    private fun getCurrencies(key: String): List<Currency>? {
        return selectedCurrencies.get(key) ?: store.get<String>(key)?.let {
            return currenciesJson.decodeFromString<List<Currency>>(it)
        }
    }

    private fun id(wallet: Wallet): String {
        return wallet.id() + "-" + wallet.network()?.id()
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