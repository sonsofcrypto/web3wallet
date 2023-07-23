package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.currencyStore.sepoliaDefaultCurrencies
import com.sonsofcrypto.web3lib.services.root.FnPollServiceRequest
import com.sonsofcrypto.web3lib.services.root.GroupPollServiceRequest
import com.sonsofcrypto.web3lib.services.root.NetworkInfo
import com.sonsofcrypto.web3lib.services.root.PollServiceRequest
import com.sonsofcrypto.web3lib.services.root.calls
import com.sonsofcrypto.web3lib.services.root.decodeCallData
import com.sonsofcrypto.web3lib.services.wallet.DefaultPollService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertTrue
import kotlin.time.Duration.Companion.seconds

class PollServiceTests {

    private val ifaceERC20 = Interface.ERC20()
    private val ifaceMulticall = Interface.Multicall3()

    private var networkInfoResultCallCount = 0
    private var balanceCallCount = 0

    @Test
    fun testExecutePoll() = runBlocking {
        networkInfoResultCallCount = 0
        balanceCallCount = 0
        val network = Network.sepolia()
        val provider = ProviderPocket(network)
        val currencies = sepoliaDefaultCurrencies
        val walletAddress = "0xA52fD940629625371775d2D7271A35a09BC2B49e"

        val requests = mutableListOf<PollServiceRequest>()
        val service = DefaultPollService(true)
        service.setProvider(provider, network)

        val balancesReqs = balancesRequests(currencies, walletAddress, network)
        val networkInfoRequest = GroupPollServiceRequest(
            "NetworkInfo.sepolia",
            NetworkInfo.calls(network.multicall3Address()),
            ::handleNetworkInfo
        )
        requests.add(networkInfoRequest)
        requests.addAll(balancesReqs)
        service.add(networkInfoRequest, network, true)
        balancesReqs.forEach { service.add(it, network, false) }
        service.executePoll(network, provider, requests)
    }

    private fun handleNetworkInfo(result: List<Any>, request: PollServiceRequest) {
        val networkInfo = NetworkInfo.decodeCallData(result as List<List<Any>>)
        networkInfoResultCallCount +=1
        println("[NETWORK INFO COUNT UPDATE] $networkInfoResultCallCount")
        assertTrue(
            networkInfo.blockNumber.isGreaterThan(BigInt.from(3946570)),
            "Block number too low: ${networkInfo.blockNumber}"
        )
        assertTrue(
            networkInfo.blockTimestamp.isGreaterThan(BigInt.from(1690083768)),
            "Block timestamp too low: ${networkInfo.blockTimestamp}"
        )
        assertTrue(
            !networkInfo.blockTimestamp.isZero(),
            "Base fee out of range: ${networkInfo.basefee}"
        )
        assertTrue(
            !networkInfo.blockGasLimit.isZero(),
            "Zero block gas limit: ${networkInfo.basefee}"
        )
    }

    private fun handleBalance(result: List<Any>, request: PollServiceRequest) {
        balanceCallCount += 1
        var currency = (request.userInfo as? Currency)
            ?: throw Throwable("Expected currency $request, $result")
        val balance = ifaceERC20.decodeFunctionResult(
            ifaceERC20.function("balanceOf"),
            result.last() as ByteArray
        ).first() as BigInt
        val expBalance = expectedBalance(currency, Network.sepolia())
        assertTrue(
            balance == expBalance && balance != null,
            "unexpected balance ${currency.name}: $balance, exp: $expBalance"
        )
    }

    private fun expectedBalance(currency: Currency, network: Network): BigInt? {
        return when(currency.name) {
            "Sepolia Ethereum" -> BigInt.from("408003475714348618", 10)
            "Sepolia WETH" -> BigInt.from("10000000000000000", 10)
            "Sepolia UNI Token" -> BigInt.from("10000000000000000000", 10)
            else -> null
        }
    }

    private fun balancesRequests(
        currencies: List<Currency>,
        walletAddress: String,
        network: Network
    ): List<PollServiceRequest> = currencies.map{
        if (it.isNative())
            FnPollServiceRequest(
                "${network.name}.${it.name}.balance",
                network.multicall3Address(),
                ifaceMulticall,
                "getEthBalance",
                listOf(walletAddress),
                ::handleBalance,
                it
            )
        else
            FnPollServiceRequest(
                "${network.name}.${it.name}.balance",
                it.address ?: throw Throwable("ERC20 missing address $it"),
                ifaceERC20,
                "balanceOf",
                listOf(walletAddress),
                ::handleBalance,
                it
            )
    }
}