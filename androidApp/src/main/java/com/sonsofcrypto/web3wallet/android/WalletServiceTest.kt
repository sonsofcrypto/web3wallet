package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.types.Network

class WalletServiceTest {

    fun runAll() {
        testCurrenciesStoring()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testCurrenciesStoring() {
        var currencyStoreService = DefaultCurrencyStoreService(
            DefaultCoinGeckoService(),
            KeyValueStore("WalletServiceTest.marketStore"),
            KeyValueStore("WalletServiceTest.candleStore"),
            KeyValueStore("WalletServiceTest.userCurrencyStore"),
        )
        val keyStoreService = DefaultKeyStoreService(
            KeyValueStore("WalletServiceTest.keyStore"),
            KeyStoreTest.MockKeyChainService()
        )
        keyStoreService.selected = mockKeyStoreItem
        val networksService = DefaultNetworksService(
            KeyValueStore("web3serviceTest"),
            keyStoreService,
        )
        var walletService = DefaultWalletService(
            networksService,
            currencyStoreService,
            KeyValueStore("WalletServiceTest.currencies"),
            KeyValueStore("WalletServiceTest.networkState"),
        )
        walletService.setCurrencies(ethereumDefaultCurrencies, Network.ethereum())
        walletService = DefaultWalletService(
            networksService,
            currencyStoreService,
            KeyValueStore("WalletServiceTest.currencies"),
            KeyValueStore("WalletServiceTest.networkState"),
        )
        assertTrue(
            walletService.currencies(Network.ethereum()).size == 4,
            "Expected four store currencies"
        )
    }
}