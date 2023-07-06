package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.ethereumDefaultCurrencies
import com.sonsofcrypto.web3lib.services.currencyStore.sepoliaDefaultCurrencies
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.node.DefaultNodeService
import com.sonsofcrypto.web3lib.services.root.NetworkInfo
import com.sonsofcrypto.web3lib.services.root.decodeNetworkInfoCallData
import com.sonsofcrypto.web3lib.services.root.networkInfoCallData
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.types.toHexStringAddress
import com.sonsofcrypto.web3lib.utils.BigInt
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

        println(network)
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
        println(" result $resultData")
        val resultDecoded = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        )
        (resultDecoded.first() as List<List<Any>>).forEach {
            val balance = ifaceERC20.decodeFunctionResult(balanceOfFn, it.last() as ByteArray)
            println("balance $balance")
        }
    }

    private val ifaceMulticall = Interface.Multicall3()
    private val ifaceERC20 = Interface.ERC20()

    // transaction count
    //
    @Test
    fun testTmp() = runBlocking {
        val network = Network.sepolia()
        val walletAddress = "0xA52fD940629625371775d2D7271A35a09BC2B49e"
        val provider = ProviderPocket(network)
        val currencies = sepoliaDefaultCurrencies
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val callData = ifaceMulticall.encodeFunction(
            aggregateFn,
            listOf(
                NetworkInfo.callData(network.multicall3Address()) +
                balancesCallData(currencies, walletAddress, network)
            )
        )
        val resultData = provider.call(
            network.multicall3Address(),
            callData.toHexString(true)
        )
        val result = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        ).first() as List<List<Any>>

        val networkInfo = NetworkInfo.decodeCallData(result)
        println("networkInfo ${networkInfo}")

        val balances = decodeBalancesCallData(result.subList(3, result.count()))
        println("balances $balances")

        for (i in 0 until currencies.count()) {
            val formatted = Formatters.currency.format(balances[i], currencies[i])
            println("${currencies[i].name} $formatted")
        }
    }


    fun balancesCallData(
        currencies: List<Currency>,
        walletAddress: String,
        network: Network
    ): List<Any> {
        val balanceOfCallData = ifaceERC20.encodeFunction(
            ifaceERC20.function("balanceOf"),
            listOf(walletAddress)
        )
        val nativeBalanceCallData = ifaceMulticall.encodeFunction(
            ifaceMulticall.function("getEthBalance"),
            listOf(walletAddress)
        )
        return currencies.map {
            if (it.isNative())
                listOf(network.multicall3Address(), true, nativeBalanceCallData)
            else
                listOf(it.address, true, balanceOfCallData)
        }
    }

    fun decodeBalancesCallData(data: List<List<Any>>): List<BigInt> = data.map {
        ifaceERC20.decodeFunctionResult(
            ifaceERC20.function("balanceOf"),
            it.last() as ByteArray
        ).first() as BigInt
    }

}

fun testWalletServices(network: Network = Network.sepolia()): WalletServices {
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
    networksService.network = network
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
    networksService.provider(networksService.network!!).debugLogs = true
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
