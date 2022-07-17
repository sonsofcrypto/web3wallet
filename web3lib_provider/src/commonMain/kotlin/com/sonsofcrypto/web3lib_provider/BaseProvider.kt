package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_core.TransactionResponse
import com.sonsofcrypto.web3lib_utils.BigInt
import com.sonsofcrypto.web3lib_utils.Timer
import kotlinx.coroutines.*
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds
import kotlin.time.ExperimentalTime

class BaseProvider : Provider  {

    private var network: Network? = null
    private var networkDeffered: Deferred<Network>? = null

    private var events: MutableList<ProviderEvent> = mutableListOf<ProviderEvent>()
    // TODO: See `BaseProvider` _emitted
    private var emittedEvents: MutableList<ProviderEvent> = mutableListOf<ProviderEvent>()

    @OptIn(ExperimentalTime::class)
    private var pollingInterval: Duration = 3.seconds
    private var poller: Timer? = null
    private var bootStrapPoll: Timer? = null

    private var lastBlockNumber: UInt = 0u
    private var maxFilterBlockRange: UInt = 0u

    private var fastBlockNumber: UInt = 0u
    private var fastBlockNumberPromise: Deferred<UInt>? = null
    private var fastQueryDate: UInt = 0u

    private var maxInternalBlockNumber: UInt = 0u
    private var internalBlockNumber: Deferred<InternalBlock>? = null

    var anyNetwork: Boolean = true
    var disableCcipRead: Boolean = false

    val scopeMain = MainScope()
    val scopeBg = CoroutineScope(Dispatchers.Default)

    @Throws(Throwable::class)
    constructor(network: Network? = null) {
        if (network != null) {
            this.network = network
            if (isKnown(network)) {
                val event = object : ProviderEventNetwork { override val network = network }
                this.emit(event)
            } else throw Error.unsupportedNetwork
        } else {
            this.networkDeffered = scopeBg.async {
               return@async detectNetwork()
            }
        }
    }

    override suspend fun network(): Network {
        TODO("Not yet implemented")
    }

    override suspend fun blockNumber(): UInt {
        TODO("Not yet implemented")
    }

    override suspend fun gasPrice(): BigInt {
        TODO("Not yet implemented")
    }

    override suspend fun balance(address: Address, block: BlockTag): BigInt {
        TODO("Not yet implemented")
    }

    override suspend fun transactionCount(address: Address, block: BlockTag): UInt {
        TODO("Not yet implemented")
    }

    override suspend fun code(address: Address, block: BlockTag): String {
        TODO("Not yet implemented")
    }

    override suspend fun storageAt(
        address: Address,
        position: BigInt,
        block: BlockTag
    ): String {
        TODO("Not yet implemented")
    }

    override suspend fun send(transaction: SignedTransaction): TransactionResponse {
        TODO("Not yet implemented")
    }

    override suspend fun call(transaction: TransactionRequest, block: BlockTag): String {
        TODO("Not yet implemented")
    }

    override suspend fun estimateGas(transaction: TransactionRequest): BigInt {
        TODO("Not yet implemented")
    }

    override suspend fun block(block: BlockTag): Block {
        TODO("Not yet implemented")
    }

    override suspend fun blockWithTransactions(block: BlockTag): Block {
        TODO("Not yet implemented")
    }

    override suspend fun transaction(hash: String): TransactionResponse {
        TODO("Not yet implemented")
    }

    override suspend fun transactionReceipt(hash: String): TransactionReceipt {
        TODO("Not yet implemented")
    }

    override suspend fun logs(filter: Filter): List<Log> {
        TODO("Not yet implemented")
    }

    override suspend fun resolveName(name: String): String? {
        TODO("Not yet implemented")
    }

    override suspend fun lookupAddress(address: Address): String? {
        TODO("Not yet implemented")
    }

    override fun on(event: ProviderEvent, providerListener: ProviderListener): Provider {
        TODO("Not yet implemented")
    }

    override fun once(event: ProviderEvent, providerListener: ProviderListener): Provider {
        TODO("Not yet implemented")
    }

    override fun emit(event: ProviderEvent): Boolean {
        TODO("Not yet implemented")
    }

    override fun listenerCount(event: ProviderEvent?): UInt {
        TODO("Not yet implemented")
    }

    override fun listeners(event: ProviderEvent?): Array<ProviderListener> {
        TODO("Not yet implemented")
    }

    override fun off(event: ProviderEvent, providerListener: ProviderListener?): Provider {
        TODO("Not yet implemented")
    }

    override fun removeAllListeners(event: ProviderEvent?): Provider {
        TODO("Not yet implemented")
    }

    override suspend fun waitForTransaction(
        transactionHash: String,
        confirmations: UInt?,
        timeout: Double
    ): TransactionReceipt {
        TODO("Not yet implemented")
    }

    /** This method should query the network if the underlying network
     *  can change, such as when connected to a JSON-RPC backend
     */
    suspend fun detectNetwork(): Network {
        throw Error.networkDetectionNotSupported
    }


    fun isKnown(network: Network): Boolean {
        // TODO: Add list of default supported networks
        return true
    }

    sealed class InternalBlock(
        number: UInt,
        reqTime: Double,
        respTime: Double,
    )

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : kotlin.Error(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** `BaseProvider` subclass does not support network detection */
        object networkDetectionNotSupported : ProviderError("provider does not support network detection")
        /** Unsuppored or invalid network */
        object unsupportedNetwork : ProviderError("Unsupported or invalid network")
    }
}