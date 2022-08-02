package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.currencies.DefaultCurrenciesService
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Network
import java.time.Clock

class CurrenciesServiceTests {

    fun runAll() {
//        testCurrenciesService()
        testCurrenciesServiceInit()
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
            KeyValueStore("CurrenciesServiceTests")
        )

        val currencies = currenciesService.defaultCurrencies(network)
        currenciesService.generateDefaultCurrenciesIfNeeded(wallet, network)
        assertTrue(
            currenciesService.currencies(wallet, network).count() == 4,
            "Unexpected currencies count after generateDefaultCurrencies"
        )
    }

    fun testCurrenciesServiceInit() {
        val clock = Clock.systemUTC()
        println("=== about to init ${clock.instant()}")
        val service = DefaultCurrenciesService(KeyValueStore("CurrenciesServiceKeyStoreTests"))
        println("=== did init ${clock.instant()}")
    }
}