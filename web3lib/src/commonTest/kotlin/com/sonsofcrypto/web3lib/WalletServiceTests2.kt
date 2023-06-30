package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.node.DefaultNodeService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.types.Currency.Companion.ethereum
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.types.Network.Companion.sepolia
import com.sonsofcrypto.web3lib.types.toHexStringAddress
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.coroutines.runBlocking
import kotlin.test.Test

class WalletServiceTests2 {

    @Test
    fun testPooling() = runBlocking {
        val services = testWalletService()
        val currencyStoreService = services.currencyStoreService
        val keyStoreService = services.keyStoreService
        val networksService = services.networksService
        val walletService = services.walletService as DefaultWalletService
        val network = sepolia()
            ?: throw Throwable("No selected network")
        val wallet = networksService.wallet(network)
            ?: throw Throwable("No wallet for network")
        val provider = wallet.provider()
            ?: throw  Throwable("Null provider")
        provider.debugLogs = true
        // TODO: Only update unselected network once per minute
        // walletService.executePoll2(wallet, currencies)
    fun testPooling() {
        val walletServices = testWalletServices()
        val service = walletServices.walletService as DefaultWalletService
        val network = service.selectedNetwork()!!
        val wallet = walletServices.networksService.wallet(network)!!
        val currencies = service.currencies(network)

        // TODO: Only update unselected network once per minute
        service.executePoll2(wallet, currencies)

        val currencies = walletService.currencies(network)
        currencies.forEach {
            println("${it.name} ${it.address}")
        }
        val currenciesAddresses = currencies.mapNotNull { it.address }

        val ifaceERC20 = Interface.ERC20()
        val ifaceMulticall = Interface.Multicall3()
        val balanceOfFn = ifaceERC20.function("balanceOf")
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val balanaceOfData = ifaceERC20.encodeFunction(
            balanceOfFn,
            listOf(wallet.address().toHexStringAddress().hexString)
        )
        val encodedData = ifaceMulticall.encodeFunction(
            aggregateFn,
            listOf(
                currenciesAddresses.map { listOf(it, true, balanaceOfData) }
            )
        )
        val resultData = provider.call(
            network.multicall3Address(),
            encodedData.toHexString(true)
        )
        val resultDecoded = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        )
        resultDecoded.forEach {
            println("$it")
        }
    }

    @Test
    fun testTmp() {
        val resultData = "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000"

        val ifaceERC20 = Interface.ERC20()
        val ifaceMulticall = Interface.Multicall3()
        val balanceOfFn = ifaceERC20.function("balanceOf")
        val aggregateFn = ifaceMulticall.function("aggregate3")

        val resultDecoded = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        )
        resultDecoded.forEach {
            ifaceERC20.decodeFunctionResult(balanceOfFn, it as ByteArray)
            println("$it")
        }
    }
}


// "club aspect deposit protect arrest leader zone crash west strong tent hammer"


fun testWalletService(): TestWalletServices {
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
    return TestWalletServices(
        currencyStoreService,
        keyStoreService,
        currencyStoreService,
        networksService,
        walletService,
    )
}

class TestWalletServices(
    val currencyStoreService: CurrencyStoreService,
    val keyStoreService: KeyStoreService,
    val networksService: NetworksService,
    val walletService: WalletService,
)

class WalletServices(
    val currencyStoreService: CurrencyStoreService,
    val networksService: NetworksService,
    val walletService: WalletService,
)
