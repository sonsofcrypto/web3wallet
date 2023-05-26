package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.node.DefaultNodeService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.types.Network
import kotlin.test.Test

class WalletServiceTests2 {

    @Test
    fun testPooling() {
        val service = testWalletService()
        val store = KeyValueStore("KeyValueTest")
//        store["ee"] = "yo"
        println(store.get<String>("ee"))

    }

}

fun testWalletService(): WalletService {
    var currencyStoreService = DefaultCurrencyStoreService(
        DefaultCoinGeckoService(),
        KeyValueStore("WalletServiceTest.marketStore"),
        KeyValueStore("WalletServiceTest.candleStore"),
        KeyValueStore("WalletServiceTest.metadataStore"),
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
        DefaultNodeService()
    )
    var walletService = DefaultWalletService(
        networksService,
        currencyStoreService,
        KeyValueStore("WalletServiceTest.currencies"),
        KeyValueStore("WalletServiceTest.networkState"),
        KeyValueStore("WalletServiceTest.transferLogCache"),
    )
    walletService.setCurrencies(ethereumDefaultCurrencies, Network.ethereum())
    walletService = DefaultWalletService(
        networksService,
        currencyStoreService,
        KeyValueStore("WalletServiceTest.currencies"),
        KeyValueStore("WalletServiceTest.networkState"),
        KeyValueStore("WalletServiceTest.transferLogCache"),
    )
    return walletService
}