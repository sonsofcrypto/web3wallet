package com.sonsofcrypto.web3lib_core

import com.sonsofcrypto.web3lib_utils.*

interface Provider {

}

typealias Address = ByteArray

class TransactionRequest {

}

class TransactionResponse {

}

interface Signer {

    fun provider(): Provider?

    /** Returns the checksum address */
    suspend fun address(): Address

    /** Signed prefixed-message. Bytes or encoded string as a UTF8-message */
    suspend fun signMessage(message: ByteArray): ByteArray

    /** Signs a transaction and returns the fully serialized, signed transaction
     * The transaction MUST be signed, and NO additional properties to be added.
     */
    @Throws(Exception::class)
    suspend fun signTransaction(transaction: TransactionRequest): ByteArray

    /** Returns a new instance of the Signer, connected to provider. */
    fun connect(provider: Provider): Signer;

    @Throws(Exception::class)
    suspend fun getBalance(block: UInt): BigInt

    @Throws(Exception::class)
    suspend fun getTransactionCount(block: UInt): UInt

    /** Populates `from` if unspecified, and estimates the fee */
    @Throws(Exception::class)
    suspend fun estimateGas(transaction: TransactionRequest): BigInt

    /** Populates "from" if unspecified, and calls with the transaction */
    suspend fun call(transaction: TransactionRequest, block: UInt? = null): ByteArray

    /** Populates all fields, signs and sends it to the network */
    suspend fun sendTransaction(transaction: TransactionRequest): TransactionResponse

    suspend fun getChainId(): Unit

    suspend fun getGasPrice(): BigInt

    suspend fun getFeeData(): FeeData

    suspend fun resolveName(name: String): String

    data class FeeData(
        val maxFeePerGas: BigInt? = null,
        val maxPriorityFeePerGas: BigInt? = null,
        val gasPrice: BigInt? = null,
    )
}
