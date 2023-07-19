package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.services.root.NetworkInfo
import com.sonsofcrypto.web3lib.services.root.NetworkPollRequest
import com.sonsofcrypto.web3lib.services.root.callData
import com.sonsofcrypto.web3lib.services.root.count
import com.sonsofcrypto.web3lib.services.root.decodeCallData
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.timerFlow
import com.sonsofcrypto.web3lib.utils.withBgCxt
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlin.time.Duration.Companion.seconds


/** `NetworkPollService` combines multiple calls into multicall, saving number
 * of calls needed */
interface NetworkPollService {

    /** Adds request to be executed with next multicall
     * @param repeat until canceled or just execute once. Default `False` */
    suspend fun add(request: NetworkPollRequest, network: Network, repeat: Boolean)
    suspend fun cancel(id: String)

    suspend fun executePoll(network: Network, requests: List<NetworkPollRequest>)

    /** Fetches balances for address & network info for `Provider.network` */
    suspend fun executePollDebug(
        walletAddress: AddressHexString,
        currencies: List<Currency>,
        networkPollRequests: List<NetworkPollRequest>,
        provider: Provider,
    ): Pair<NetworkInfo, List<BigInt>>
}

class DefaultNetworkPollService: NetworkPollService {
    private val ifaceMulticall = Interface.Multicall3()
    private var repeatIds: MutableList<String> = mutableListOf()
    private var requests: MutableMap<Network, MutableList<NetworkPollRequest>>
        = mutableMapOf()
    private val mutex = Mutex()
    private var poolJob: Job = timerFlow(15.seconds, initialDelay = 1.seconds)
        .onEach { poll() }
        .launchIn(CoroutineScope(bgDispatcher))

    constructor(blockTimer: Boolean = false) {
        if (blockTimer) poolJob.cancel()
    }

    override suspend fun add(
        request: NetworkPollRequest,
        network: Network,
        repeat: Boolean
    ) = mutex.withLock {
        var list = requests[network] ?: mutableListOf()
        list.add(request)
        requests[network] = list
        if (repeat)
            repeatIds.add(request.id)
    }

    override suspend fun cancel(id: String) = mutex.withLock {
        val tmp = repeatIds.remove(id)
    }

    private suspend fun poll() = withBgCxt {
        val requests = mutex.withLock { requests.toMap() }
        requests.keys.forEach { executePoll(it, requests[it] ?: emptyList()) }
        // TODO: Pool testnets only every 45 seconds
        // TODO: Optimize time to that is gets called just as new block was created
    }

    override suspend fun executePoll(network: Network, requests: List<NetworkPollRequest>) {
        if (requests.isEmpty()) return
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val callData = listOf(requests.map { it.toMultiCall3List() })
        val resultData = requests.first().provider.call(
            requests.first().provider.network.multicall3Address(),
            ifaceMulticall.encodeFunction(aggregateFn, callData).toHexString(true)
        )
        val result = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        ).first() as List<List<Any>>
        handlePollLoopRequests(requests, result, network)
    }

    private suspend fun handlePollLoopRequests(
        requests: List<NetworkPollRequest>,
        results: List<List<Any>>,
        network: Network
    ) = withBgCxt {
        removeExecuted(requests, network)
        requests.forEachIndexed { idx, req -> req.handler(results[idx]) }
    }

    private suspend fun removeExecuted(
        requests: List<NetworkPollRequest>,
        network: Network
    ) = mutex.withLock {
        this.requests[network] = requests
            .filter { repeatIds.contains(it.id) }
            .toMutableList()
    }

    private val ifaceERC20 = Interface.ERC20()

    override suspend fun executePollDebug(
        walletAddress: AddressHexString,
        currencies: List<Currency>,
        requests: List<NetworkPollRequest>,
        provider: Provider,
    ): Pair<NetworkInfo, List<BigInt>> {
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val callData = listOf(
            NetworkInfo.callData(provider.network.multicall3Address()) +
            balancesCallData(currencies, walletAddress, provider.network) +
            requests.map { it.toMultiCall3List() }
        )
        val resultData = provider.call(
            provider.network.multicall3Address(),
            ifaceMulticall.encodeFunction(aggregateFn, callData).toHexString(true)
        )
        val result = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        ).first() as List<List<Any>>

        var reqRng = NetworkInfo.count() + currencies.count() to result.count()

        handleNetworkInfo(result)
        handleBalances(result.subList(NetworkInfo.count(), NetworkInfo.count() + currencies.count()))
//        handlePollLoopRequests(requests, result.subList(reqRng.first, reqRng.second))

        return Pair(
            NetworkInfo.decodeCallData(result),
            decodeBalancesCallData(
                result.subList(NetworkInfo.count(), NetworkInfo.count() + currencies.count())
            ),
        )
    }

    private fun handleNetworkInfo(data: List<List<Any>>) {
        NetworkInfo.decodeCallData(data)
    }

    private fun handleBalances(data: List<List<Any>>) {
        data.map {
            ifaceERC20.decodeFunctionResult(
                ifaceERC20.function("balanceOf"),
                it.last() as ByteArray
            ).first() as BigInt
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