package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.serialization.json.JsonPrimitive

/** Block tag */
sealed class BlockTag() {
    object Earliest : BlockTag()
    object Latest : BlockTag()
    object Pending : BlockTag()
    data class Number(val number: Long) : BlockTag()
    data class Hash(val hash: String) : BlockTag()

    fun jsonPrimitive(): JsonPrimitive = when (this) {
        Earliest -> JsonPrimitive("earliest")
        Latest -> JsonPrimitive("latest")
        Pending -> JsonPrimitive("pending")
        is Number -> JsonPrimitive(QuantityHexString(number))
        is Hash -> JsonPrimitive(hash)
    }
}

/** Abstract Provider */
abstract class Provider {

    /** Network */

    abstract suspend fun network(): Network
    abstract suspend fun blockNumber(): UInt
    abstract suspend fun gasPrice(): BigInt

    @Throws(Throwable::class)
    suspend fun feeData(): FeeData = coroutineScope {
        val blockAsync = async { block() }
        val gasPriceAsync = async { gasPrice() }

        val block = blockAsync.await()
        val gasPrice = gasPriceAsync.await()

        if (block.baseFeePerGas == null) {
            throw Error.feeDataNullBaseFeePerGas
        }

        // TODO: We may want to compute this more accurately in the future,
        // using the formula "check if the base fee is correct".
        // See: https://eips.ethereum.org/EIPS/eip-1559
        val maxPriorityFeePerGas = BigInt.from("1500000000")
        val maxFeePerGas = block.baseFeePerGas!!
            .mul(BigInt.from(2))
            .add(maxPriorityFeePerGas)
        return@coroutineScope object: FeeData {
            override val maxFeePerGas = maxFeePerGas
            override val maxPriorityFeePerGas = maxPriorityFeePerGas
            override val gasPrice = gasPrice
        }
    }

    /** Account */

    abstract suspend fun balance(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): BigInt

    abstract suspend fun transactionCount(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): UInt

    abstract suspend fun code(
        address: Address,
        block: BlockTag = BlockTag.Latest
    ): String

    abstract suspend fun storageAt(
        address: Address,
        position: BigInt,
        block: BlockTag = BlockTag.Latest
    ): String

    /** Execution */

    abstract suspend fun send(transaction: SignedTransaction): TransactionResponse

    abstract suspend fun call(
        transaction: TransactionRequest,
        block: BlockTag = BlockTag.Latest
    ): String

    abstract suspend fun estimateGas(transaction: TransactionRequest): BigInt

    /** Queries */

    abstract suspend fun block(block: BlockTag = BlockTag.Latest): Block

    abstract suspend fun blockWithTransactions(
        block: BlockTag = BlockTag.Latest
    ): Block

    abstract suspend fun transaction(hash: String): TransactionResponse

    abstract suspend fun transactionReceipt(hash: String): TransactionReceipt

    /** Bloom-filter queries */
    abstract suspend fun logs(filter: Filter): List<Log>

    /** Name service */
    abstract suspend fun resolveName(name: String): String?
    abstract suspend fun lookupAddress(address: Address): String?

    /** Event emitter */

    abstract fun on(event: Event, providerListener: Listener): Provider
    abstract fun once(event: Event, providerListener: Listener): Provider
    abstract fun emit(event: Event): Boolean
    abstract fun listenerCount(event: Event? = null): UInt
    abstract fun listeners(event: Event? = null): Array<Listener>
    abstract fun off(event: Event, providerListener: Listener? = null): Provider
    abstract fun removeAllListeners(event: Event? = null): Provider

    abstract suspend fun waitForTransaction(
        transactionHash: String,
        confirmations: UInt?,
        timeout: Double)
            : TransactionReceipt

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : kotlin.Error(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** Unable to compute `FeeData` due to missing `Block.baseFeePerGas` */
        object feeDataNullBaseFeePerGas :
            Error("Unable to compute `FeeData` due to missing `Block.baseFeePerGas`")
    }
}
