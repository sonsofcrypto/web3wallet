package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.currencies.DefaultCurrenciesInfoStore
import com.sonsofcrypto.web3lib.services.currencies.DefaultCurrenciesService
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.timerFlow
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import java.time.Clock
import kotlin.time.Duration.Companion.seconds

class CurrenciesServiceTests {

    val currenciesInfoStore = DefaultCurrenciesInfoStore()
    val updatesTickJob = timerFlow(2.seconds)
    .onEach { checkCurrencies() }
    .launchIn(CoroutineScope(bgDispatcher))

    fun runAll() {
        testCurrenciesService()
//        testCurrenciesServiceInit()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testCurrenciesService() {
        val network = Network.ethereum()
        val keyValueStore = KeyValueStore("CurrenciesServiceKeyStoreTests")
        val keyStore = DefaultKeyStoreService(
            keyValueStore,
            KeyStoreTest.MockKeyChainService()
        )
        val wallet = Wallet(mockKeyStoreItem, keyStore)
        val currenciesService = DefaultCurrenciesService(
            KeyValueStore("CurrenciesServiceTests"),
            currenciesInfoStore
        )

        val currencies = currenciesService.defaultCurrencies(network)
        currenciesService.generateDefaultCurrenciesIfNeeded(wallet)
        assertTrue(
            currenciesService.currencies(wallet).count() == 4,
            "Unexpected currencies count after generateDefaultCurrencies"
        )

        runBlocking {
            currenciesInfoStore.loadCurrencies()
        }

    }

    fun checkCurrencies() {
        val info = currenciesInfoStore.info(Currency.ethereum())
        print("=== colors ${info?.colors}")
    }

    fun testCurrenciesServiceInit() {
        val clock = Clock.systemUTC()
        println("=== about to init ${clock.instant()}")
        val service = DefaultCurrenciesService(
            KeyValueStore("CurrenciesServiceKeyStoreTests"),
            DefaultCurrenciesInfoStore()
        )
        println("=== did init ${clock.instant()}")
    }
}