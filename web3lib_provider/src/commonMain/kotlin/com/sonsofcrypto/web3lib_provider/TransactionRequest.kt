package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.*
import com.sonsofcrypto.web3lib_core.TransactionResponse
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.coroutines.*

data class TransactionRequest(
    val to: AddressBytes?,
    val from: AddressBytes?,
    val nonce: BigInt?,

    val gasLimit: BigInt?,
    val gasPrice: BigInt?,

    val data: ByteArray?,
    val value: BigInt?,
    val chainId: Int?,

    val type: TransactionType?,
    val accessList: AccessList?,

    val maxPriorityFeePerGas: BigInt?,
    val maxFeePerGas: BigInt?,

    val customData: Map<String, Any>?,
    val ccipReadEnabled: Boolean?, // EIP-3668
)

interface TransactionResponse {
    val hash: String

    val blockNumber: UInt?
    val blockHash: String?
    val timestamp: Double?

    val confirmations: UInt

    val from: AddressBytes

    val raw: ByteArray?

    val gasLimit: BigInt?
    val gasPrice: BigInt?
}

interface _Block {
    val hash: String
    val parentHash: String
    val number: UInt

    val timestamp: Double
    val nonce: UInt
    val difficulty: UInt

    val gasLimit: BigInt
    val gasUsed: BigInt

    val miner: String
    val extraData: String

    val baseFeePerGas: BigInt?
}

interface Block: _Block {
    val transactions: List<String>
}

interface BlockWithTransactions: _Block {
    val transactions: Array<TransactionResponse>
}

interface Log {
    val blockNumber: UInt
    val blockHash: String
    val transactionIndex: UInt

    val removed: Boolean

    val address: AddressBytes
    val data: ByteArray

    val topics: Array<String>

    val transactionHash: String
    val logIndex: UInt
}

interface TransactionReceipt {
    val to: AddressBytes
    val from: AddressBytes
    val contractAddress: AddressBytes
    val transactionIndex: UInt
    val root: String
    val gasUsed: BigInt
    val logsBloom: String
    val blockHash: String
    val transactionHash: String
    val logs: Array<Log>
    val blockNumber: UInt
    val confirmations: UInt
    val cumulativeGasUsed: BigInt
    val effectiveGasPrice: BigInt
    val byzantium: Boolean
    val type: TransactionType
    val status: UInt?
}

interface FeeData {
    val maxFeePerGas: BigInt
    val maxPriorityFeePerGas: BigInt
    val gasPrice: BigInt
}

/** Errors */
sealed class ProviderError(
    message: String? = null,
    cause: Throwable? = null
) : kotlin.Error(message, cause) {

    constructor(cause: Throwable) : this(null, cause)

    /** Unable to compute `FeeData` due to missing `Block.baseFeePerGas` */
    object feeDataNullBaseFeePerGas : ProviderError("Unable to compute `FeeData` due to missing `Block.baseFeePerGas`")
}

/** Block tag */
sealed class BlockTag() {
    object Latest : BlockTag()
    data class Number(val number: Int) : BlockTag()
    data class Hash(val hash: String) : BlockTag()
}

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
            throw ProviderError.feeDataNullBaseFeePerGas
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

    abstract fun on(event: ProviderEvent, providerListener: ProviderListener): Provider
    abstract fun once(event: ProviderEvent, providerListener: ProviderListener): Provider
    abstract fun emit(event: ProviderEvent): Boolean
    abstract fun listenerCount(event: ProviderEvent? = null): UInt
    abstract fun listeners(event: ProviderEvent? = null): Array<ProviderListener>
    abstract fun off(event: ProviderEvent, providerListener: ProviderListener? = null): Provider
    abstract fun removeAllListeners(event: ProviderEvent? = null): Provider

    abstract suspend fun waitForTransaction(
        transactionHash: String,
        confirmations: UInt?,
        timeout: Double)
    : TransactionReceipt

}

class Tmp {

    val scopeMain = MainScope()
    val scopeBg = CoroutineScope(Dispatchers.Default)

    var myVal: Int = 23

    fun someFun() {
        scopeBg.launch {

            scopeMain.launch {
                myVal = 3
            }
        }
    }

    fun destroy() {
        scopeMain.cancel()
        scopeBg.cancel()
    }
}



