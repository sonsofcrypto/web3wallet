package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.services.root.PollServiceRequest
import com.sonsofcrypto.web3lib.types.Network
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
interface PollService {

    /** Adds request to be executed with next multicall
     * @param repeat until canceled or just execute once. Default `False` */
    suspend fun add(
        request: PollServiceRequest,
        network: Network,
        repeat: Boolean
    )

    /** Cancel repeating request */
    suspend fun cancel(id: String)

    /** Provider to be used for given network */
    suspend fun setProvider(provider: Provider, network: Network)

    /** Errors */
    sealed class Error(message: String? = null) : Exception(message) {
        data class MissingProvider(val network: Network):
            Error("Missing provider for $network")
    }
}

class DefaultPollService: PollService {
    private val ifaceMulticall = Interface.Multicall3()
    private var repeatIds: MutableList<String> = mutableListOf()
    private var providers: MutableMap<Network, Provider> = mutableMapOf()
    private var requests: MutableMap<Network, MutableList<PollServiceRequest>>
        = mutableMapOf()
    private val mutex = Mutex()
    private var poolJob: Job = timerFlow(15.seconds, initialDelay = 1.seconds)
        .onEach { poll() }
        .launchIn(CoroutineScope(bgDispatcher))

    constructor(blockTimer: Boolean = false) {
        if (blockTimer) poolJob.cancel()
    }

    override suspend fun add(
        request: PollServiceRequest,
        network: Network,
        repeat: Boolean
    ) = mutex.withLock {
        var list = requests[network] ?: mutableListOf()
        list.add(request)
        requests[network] = list
        if (repeat)
            repeatIds.add(request.id)
    }

    override suspend fun cancel(id: String)
        = mutex.withLock { val tmp = repeatIds.remove(id) }

    override suspend fun setProvider(provider: Provider, network: Network)
        = mutex.withLock { providers[network] = provider  }

    private suspend fun poll() = withBgCxt {
        val requests = mutex.withLock { requests.toMap() }
        val provides = mutex.withLock { providers.toList() }
        // TODO: Pool testnets only every 45 seconds
        // TODO: Optimize time to that is gets called just as new block was created
        requests.keys.forEach {
            executePoll(
                it,
                providers[it] ?: throw PollService.Error.MissingProvider(it),
                requests[it] ?: emptyList()
            )
        }
    }

    /** @note only public for unit test purposes should never be called directly */
    suspend fun executePoll(
        network: Network,
        provider: Provider,
        requests: List<PollServiceRequest>
    ) {
        if (requests.isEmpty()) return
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val calls = mutableListOf<List<Any>>()
        requests.forEach { c ->
            calls.addAll(c.calls().map { it.toList() })
        }
        println("[CALLS] $calls")
        val resultData = provider.call(
            provider.network.multicall3Address(),
            ifaceMulticall.encodeFunction(aggregateFn, listOf(calls)).toHexString(true)
        )
        println("[RESULT DATA] $resultData")
        val result = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            (resultData as DataHexString).toByteArrayData()
        ).first() as List<List<Any>>
        handlePollLoopRequests(requests, result, network)
    }

    private suspend fun handlePollLoopRequests(
        requests: List<PollServiceRequest>,
        results: List<List<Any>>,
        network: Network
    ) = withBgCxt {
        removeExecuted(requests, network)
        var currIdx = 0
        println("[COUNT] ${requests.count()} ${results.count()}")
        requests.forEachIndexed { idx, req ->
            println("$currIdx, ${currIdx + req.callCount} ${req.callCount}")
            if (req.callCount == 1) req.handler(results[currIdx])
            else req.handler(results.subList(currIdx, currIdx + req.callCount))
            currIdx += req.callCount
        }
    }

    private suspend fun removeExecuted(
        requests: List<PollServiceRequest>,
        network: Network
    ) = mutex.withLock {
        this.requests[network] = requests
            .filter { repeatIds.contains(it.id) }
            .toMutableList()
    }

//    private val ifaceERC20 = Interface.ERC20()
//
//    override suspend fun executePollDebug(
//        walletAddress: AddressHexString,
//        currencies: List<Currency>,
//        requests: List<FnPollServiceRequest>,
//        provider: Provider,
//    ): Pair<NetworkInfo, List<BigInt>> {
//        val aggregateFn = ifaceMulticall.function("aggregate3")
//        val callData = listOf(
//            NetworkInfo.callData(provider.network.multicall3Address()) +
//            balancesCallData(currencies, walletAddress, provider.network) +
//            requests.map { it.toMultiCall3List() }
//        )
//        val resultData = provider.call(
//            provider.network.multicall3Address(),
//            ifaceMulticall.encodeFunction(aggregateFn, callData).toHexString(true)
//        )
//        val result = ifaceMulticall.decodeFunctionResult(
//            aggregateFn,
//            resultData.toByteArrayData()
//        ).first() as List<List<Any>>
//
//        var reqRng = NetworkInfo.count() + currencies.count() to result.count()
//
//        handleNetworkInfo(result)
//        handleBalances(result.subList(NetworkInfo.count(), NetworkInfo.count() + currencies.count()))
////        handlePollLoopRequests(requests, result.subList(reqRng.first, reqRng.second))
//
//        return Pair(
//            NetworkInfo.decodeCallData(result),
//            decodeBalancesCallData(
//                result.subList(NetworkInfo.count(), NetworkInfo.count() + currencies.count())
//            ),
//        )
//    }
//
//    private fun handleNetworkInfo(data: List<List<Any>>) {
//        NetworkInfo.decodeCallData(data)
//    }
//
//    private fun handleBalances(data: List<List<Any>>) {
//        data.map {
//            ifaceERC20.decodeFunctionResult(
//                ifaceERC20.function("balanceOf"),
//                it.last() as ByteArray
//            ).first() as BigInt
//        }
//    }
//
//    fun balancesCallData(
//        currencies: List<Currency>,
//        walletAddress: String,
//        network: Network
//    ): List<Any> {
//        val balanceOfCallData = ifaceERC20.encodeFunction(
//            ifaceERC20.function("balanceOf"),
//            listOf(walletAddress)
//        )
//        val nativeBalanceCallData = ifaceMulticall.encodeFunction(
//            ifaceMulticall.function("getEthBalance"),
//            listOf(walletAddress)
//        )
//        return currencies.map {
//            if (it.isNative())
//                listOf(network.multicall3Address(), true, nativeBalanceCallData)
//            else
//                listOf(it.address, true, balanceOfCallData)
//        }
//    }
//
//    fun decodeBalancesCallData(data: List<List<Any>>): List<BigInt> = data.map {
//        ifaceERC20.decodeFunctionResult(
//            ifaceERC20.function("balanceOf"),
//            it.last() as ByteArray
//        ).first() as BigInt
//    }
}