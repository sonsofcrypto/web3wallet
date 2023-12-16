package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreEvent
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreListener
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import kotlinx.coroutines.runBlocking
import kotlinx.datetime.Clock
import kotlin.test.Test
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

class CurrencyStoreServiceTest: CurrencyStoreListener {

    private var event: CurrencyStoreEvent? = null

    private val service = DefaultCurrencyStoreService(
        DefaultCoinGeckoService(),
        KeyValueStore("CurrencyStoreServiceTest.Market"),
        KeyValueStore("CurrencyStoreServiceTest.Candle"),
        KeyValueStore("CurrencyStoreServiceTest.MetadataStore"),
        KeyValueStore("CurrencyStoreServiceTest.UserCurrency"),
    )

    @Test
    fun testDebug() {

    }

    @Test
    fun testCacheLoading() {
        val listener = this
        runBlocking {
            service.add(listener)
            val start = Clock.System.now().toEpochMilliseconds()
            val job = service.loadCaches(NetworksService.supportedNetworks())
            job.join()
            val end = Clock.System.now().toEpochMilliseconds()
            assertTrue(end - start < 500, "Took too long to load")
            println("Currencies load time ${(end - start)}")
            val currencies = service.search("E", Network.ethereum(), 0)
            assertTrue(currencies.count() >= 172,"Search error ${currencies.size}")
        }
    }

    @Test
    fun testMarkets() = runBlocking {
        try {
            val markets = service.fetchMarketData(listOf(Currency.ethereum()))
            val candles = service.fetchCandles(Currency.ethereum())
            assertNotEquals(markets, null, "Failed to fetch markets")
            assertNotEquals(candles, null, "Failed to fetch candles")
        } catch (err: Throwable) {
            println("=== Caught $err")
        }
    }

    override fun handle(event: CurrencyStoreEvent) {
        this.event = event
    }
}
