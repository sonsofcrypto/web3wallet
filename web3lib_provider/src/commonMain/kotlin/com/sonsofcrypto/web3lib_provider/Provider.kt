package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_provider.model.BlockTag
import com.sonsofcrypto.web3lib_provider.model.BlockTag.Latest
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.serialization.json.JsonObject

interface SignedTransaction {}

/** Abstract Provider web3 JSON-RPC API */
abstract class Provider {

    abstract val network: Network

    /** Gossip */

    @Throws(Throwable::class)
    abstract suspend fun blockNumber(): BigInt

    @Throws(Throwable::class)
    abstract suspend fun gasPrice(): BigInt

    @Throws(Throwable::class) abstract suspend
    fun sendRawTransaction(transaction: DataHexString): DataHexString

    /** State */

    @Throws(Throwable::class) abstract suspend
    fun getBalance(address: Address, block: BlockTag = Latest): BigInt

    @Throws(Throwable::class) abstract suspend
    fun getStorageAt(address: Address, position: ULong, block: BlockTag = Latest): DataHexString

    @Throws(Throwable::class) abstract suspend
    fun getTransactionCount(address: Address, block: BlockTag = Latest): BigInt

    @Throws(Throwable::class) abstract suspend
    fun getCode(address: Address, block: BlockTag = Latest): DataHexString

    @Throws(Throwable::class) abstract suspend
    fun call(transaction: TransactionRequest, block: BlockTag = Latest): DataHexString

    @Throws(Throwable::class) abstract suspend
    fun estimateGas(transaction: Transaction): BigInt

    @Throws(Throwable::class) abstract suspend
    fun feeData(): FeeData

    /** History */

    @Throws(Throwable::class) abstract suspend
    fun getBlockTransactionCount(block: BlockTag): ULong

    @Throws(Throwable::class) abstract suspend
    fun getUncleCount(block: BlockTag): ULong

    @Throws(Throwable::class) abstract suspend
    fun getBlock(block: BlockTag, full: Boolean = false): Block

    @Throws(Throwable::class) abstract suspend
    fun getTransaction(hash: DataHexString): Transaction

    @Throws(Throwable::class) abstract suspend
    fun getTransaction(block: BlockTag, index: BigInt): Transaction

    @Throws(Throwable::class) abstract suspend
    fun getTransactionReceipt(hash: String): TransactionReceipt

    @Throws(Throwable::class) abstract suspend
    fun getUncleBlock(block: BlockTag, index: BigInt): Block

    @Throws(Throwable::class) abstract suspend
    fun getLogs(filterRequest: FilterRequest): List<Any>

    @Throws(Throwable::class) abstract suspend
    fun newFilter(filterRequest: FilterRequest): QuantityHexString

    @Throws(Throwable::class) abstract suspend
    fun newBlockFilter(): QuantityHexString

    @Throws(Throwable::class) abstract suspend
    fun newPendingTransactionFilter(): QuantityHexString

    @Throws(Throwable::class) abstract suspend
    fun getFilterChanges(id: QuantityHexString): JsonObject

    @Throws(Throwable::class) abstract suspend
    fun getFilterLogs(id: QuantityHexString): JsonObject

    @Throws(Throwable::class) abstract suspend
    fun uninstallFilter(id: QuantityHexString): Boolean

    /** Name service */

    @Throws(Throwable::class) abstract suspend
    fun resolveName(name: String): String?

    @Throws(Throwable::class) abstract suspend
    fun lookupAddress(address: Address): String?

    /** Event emitter */

    abstract fun on(event: Event, providerListener: Listener): Provider
    abstract fun once(event: Event, providerListener: Listener): Provider
    abstract fun emit(event: Event): Boolean
    abstract fun listenerCount(event: Event? = null): UInt
    abstract fun listeners(event: Event? = null): Array<Listener>
    abstract fun off(event: Event, providerListener: Listener? = null): Provider
    abstract fun removeAllListeners(event: Event? = null): Provider

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : kotlin.Error(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** Unable to compute `FeeData` due to missing `Block.baseFeePerGas` */
        object feeDataNullBaseFeePerGas :
            Error("Unable to compute `FeeData` due to missing `Block.baseFeePerGas`")

        /** Initialized provider with unsupported network */
        data class UnsupportedNetwork(val network: Network) :
            Error("Unsupported network $network")
    }
}
