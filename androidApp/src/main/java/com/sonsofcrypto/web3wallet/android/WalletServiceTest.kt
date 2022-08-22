package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.currencyStore.ropstenDefaultCurrencies
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

class WalletServiceTest {

    val scope = CoroutineScope(bgDispatcher)

    fun runAll() {
//        testCurrenciesStoring()
        testSend()
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testCurrenciesStoring() {
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

    fun testSend() {
        // 0x58aEBEC033A2D55e35e44E6d7B43725b069F6Abc
        val mnemonic = "ignore such face concert soccer above topple flavor kiwi salad online peace"
        val bip39 = Bip39(mnemonic.split(" "), "", WordList.ENGLISH)
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        val key = bip44.deriveChildKey("m/44'/60'/0'/0/0")
        val address = Address.Bytes(Network.ropsten().address(key))
        // draft timber rude maze flavor october tip carbon use item cross fashion
        //0xdbf95f925A4FfA270f9a4B5FC55F8d72cCb5a98f
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
        val testKeyStoreItem = KeyStoreItem(
            uuid = "WalletServiceTest.001",
            name = "Test wallet 001",
            sortOrder = 0u,
            type = KeyStoreItem.Type.MNEMONIC,
            passUnlockWithBio = true,
            iCloudSecretStorage = true,
            saltMnemonic = false,
            passwordType = KeyStoreItem.PasswordType.PASS,
            derivationPath = "m/44'/60'/0'/0/0",
            addresses = mapOf(
                "m/44'/60'/0'/0/0" to "0x58aEBEC033A2D55e35e44E6d7B43725b069F6Abc",
            ),
        )
        val password = "SomeLongPassword"
        val secretStorage = SecretStorage.encryptDefault(
            id = testKeyStoreItem.uuid,
            data = key.key,
            password = password,
            address = address.toHexStringAddress().hexString,
            mnemonic = mnemonic,
            mnemonicLocale = WordList.ENGLISH.localeString(),
            mnemonicPath = "m/44'/60'/0'/0/0",
        )
        keyStoreService.add(testKeyStoreItem, password, secretStorage)
        keyStoreService.selected = testKeyStoreItem
        val networksService = DefaultNetworksService(
            KeyValueStore("web3serviceTest"),
            keyStoreService,
        )
        networksService.setNetwork(Network.ropsten(), enabled = true)
        networksService.network = Network.ropsten()
        var walletService = DefaultWalletService(
            networksService,
            currencyStoreService,
            KeyValueStore("WalletServiceTest.currencies"),
            KeyValueStore("WalletServiceTest.networkState"),
        )
        walletService.setCurrencies(ropstenDefaultCurrencies, Network.ropsten())
        walletService.unlock(password, "", Network.ropsten())
        scope.launch {
            val result = walletService.transfer(
                "0xdbf95f925A4FfA270f9a4B5FC55F8d72cCb5a98f",
                Currency.ethereum(),
                BigInt.from("1000000000000000"),
                Network.ropsten()
            )
            println("=== result $result")
        }
    }
}
