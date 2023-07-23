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
        val resultData = provider.call(
            provider.network.multicall3Address(),
            ifaceMulticall.encodeFunction(aggregateFn, listOf(calls)).toHexString(true)
        )
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
        requests.forEachIndexed { idx, req ->
            if (req.callCount == 1) req.handler(results[currIdx], req)
            else req.handler(results.subList(currIdx, currIdx + req.callCount), req)
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
}