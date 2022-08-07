package com.sonsofcrypto.web3lib.services.currencies

import com.sonsofcrypto.web3lib.services.currencies.model.CurrencyInfo
import com.sonsofcrypto.web3lib.services.currencies.model.listFrom
import com.sonsofcrypto.web3lib.services.currencyMetadata.BundledAssetProvider
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.Trie
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import io.ktor.util.*
import kotlinx.coroutines.*

interface CurrenciesInfoStore {
    var currencies: List<Currency>
    fun currencies(search: String): List<Currency>
    fun info(currency: Currency): CurrencyInfo?

    suspend fun loadCurrencies()
}

class DefaultCurrenciesInfoStore: CurrenciesInfoStore {
    override var currencies: List<Currency> = listOf()
    private var info: Map<String, CurrencyInfo> = mapOf()
    private var namesTrie: Trie = Trie()
    private var symbolsTrie: Trie = Trie()
    private var namesMap: Map<String, Int> = emptyMap()
    private var symbolsMap: Map<String, Int> = emptyMap()
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)

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

    override fun info(currency: Currency): CurrencyInfo? = info[currency.id()]


    override suspend fun loadCurrencies() {
        scope.launch(newSingleThreadContext("coin_cache_loading")) {
            val data = BundledAssetProvider().file("coin_cache", "json")
            val jsonString = data?.decodeToString() ?: "[]"
            val info = CurrencyInfo.listFrom(jsonString)
            val infoMap = mutableMapOf<String, CurrencyInfo>()
            val currencies = info.map {
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
            for (idx in currencies.indices) {
                infoMap.put(currencies[idx].id(), info[idx])
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
                    infoMap,
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
        info: Map<String, CurrencyInfo>,
        namesTrie: Trie,
        symbolsTrie: Trie,
        namesMap: Map<String, Int>,
        symbolsMap: Map<String, Int>,
    ) {
        this.currencies = currencies
        this.info = info
        this.namesTrie = namesTrie
        this.symbolsTrie = symbolsTrie
        this.namesMap = namesMap
        this.symbolsMap = symbolsMap
    }
}