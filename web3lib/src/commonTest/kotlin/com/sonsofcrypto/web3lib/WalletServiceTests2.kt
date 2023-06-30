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
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.types.toHexStringAddress
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.coroutines.runBlocking
import kotlin.test.Test

class WalletServiceTests2 {

    @Test
    fun testPooling() = runBlocking {
        val walletServices = testWalletServices()
        val walletService = walletServices.walletService as DefaultWalletService
        val networksService = walletServices.networksService
        val network = walletService.selectedNetwork()!!
        val wallet = walletServices.networksService.wallet(network)!!
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
        val provider = networksService.provider(network)
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

fun testWalletServices(): WalletServices {
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
    return WalletServices(
        currencyStoreService,
        keyStoreService,
        networksService,
        walletService,
    )
}

class WalletServices(
    val currencyStoreService: CurrencyStoreService,
    val keyStoreService: KeyStoreService,
    val networksService: NetworksService,
    val walletService: WalletService,
)
