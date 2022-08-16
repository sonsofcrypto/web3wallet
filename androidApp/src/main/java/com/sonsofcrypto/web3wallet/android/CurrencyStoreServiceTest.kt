package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreEvent
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreListener
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.subListTo
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.time.Clock
import java.time.Duration
import java.time.Instant

class CurrencyStoreServiceTest: CurrencyStoreListener {

    private val service = DefaultCurrencyStoreService()
    private val scope = CoroutineScope(bgDispatcher)

    fun runAll() {
        testCacheLoading()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testCacheLoading() {
        val listener = this
        scope.launch {
            service.add(listener)
            val start = Clock.systemUTC().instant()
            val job = service.loadCaches(NetworksService.supportedNetworks())
            job.join()
            val duration = Duration.between(start, Clock.systemUTC().instant())
            val count = service.currencies(Network.ethereum(), 0).count()
            println("=== Load time ${duration.seconds} ${duration.toMillis()} ${count}")
        }
    }

    fun testSearch() {
        val currencies = service.search("E", Network.ethereum(), 0)
        assertTrue(currencies.size == 237, "Search error ${currencies.size}")
    }

    override fun handle(event: CurrencyStoreEvent) {
        println("=== event $event")
        testSearch()
    }
}

