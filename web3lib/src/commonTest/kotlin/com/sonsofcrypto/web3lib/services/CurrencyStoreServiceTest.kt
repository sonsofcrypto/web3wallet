package com.sonsofcrypto.web3lib.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreEvent
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreListener
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.FileManager
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.runBlocking
import kotlinx.datetime.Clock
import kotlin.test.Test
import kotlin.test.assertTrue


class CurrencyStoreServiceTest: CurrencyStoreListener {

    private val service = DefaultCurrencyStoreService(
        DefaultCoinGeckoService(),
        KeyValueStore("CurrencyStoreServiceTest.Market"),
        KeyValueStore("CurrencyStoreServiceTest.Candle"),
        KeyValueStore("CurrencyStoreServiceTest.MetadataStore"),
        KeyValueStore("CurrencyStoreServiceTest.UserCurrency"),
    )

    private val scope = CoroutineScope(bgDispatcher)
    private var lastEvent: CurrencyStoreEvent? = null

    @Test
    fun debug() {
        val fileName = "currencies_meta/cache_currencies_11155111_arr.json"
        val jsonStr =FileManager()
            .readSync(fileName, FileManager.Location.BUNDLE)
            .decodeToString()
        val arrayReps = jsonDecode<List<List<String>>>(jsonStr) ?: emptyList()
        val currencies = arrayReps.map {
            Currency(
                symbol = it[0],
                name = it[1],
                coinGeckoId = it[2],
                address = it.getOrNull(3),
                decimals = it.getOrNull(4)?.toUIntOrNull(),
            )
        }
        println("Result $currencies")
    }

    @Test
    fun testCacheLoading() {
        val listener = this
        runBlocking {
            service.add(listener)
            val start = Clock.System.now()
            val job = service.loadCaches(NetworksService.supportedNetworks())
            job.join()
            val duration = Clock.System.now().minus(start)
            val count = service.currencies(Network.ethereum(), 1000).count()
            assertTrue(
                duration.inWholeMilliseconds < 500,
                "Took too long to load caches ${duration.inWholeMilliseconds}"
            )
            assertTrue(
                lastEvent == CurrencyStoreEvent.CacheLoaded,
                "Expected cache to be loaded by now"
            )
            assertTrue(count == 1000, "Expected more ETH currencies $count")

            val currencies = service.search("E", Network.ethereum(), 0)
            assertTrue(currencies.size >= 172, "Search error ${currencies.size}")
        }
    }

    @Test
    fun testMarkets() = runBlocking {
        try {
            val markets = service.fetchMarketData(listOf(Currency.ethereum()))
            val candles = service.fetchCandles(Currency.ethereum())
            assertTrue(markets != null && markets.isNotEmpty(), "Failed to fetch markets")
            assertTrue(candles != null && candles.isNotEmpty(), "Failed to fetch candles")
        } catch (err: Throwable) {
            assertTrue(false, "$err")
        }
    }

    override fun handle(event: CurrencyStoreEvent) {
        lastEvent = event
    }
}

