package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.provider.model.BlockTag.Latest

interface Signer {

    fun provider(): Provider?

    /** Returns the checksum address */
    @Throws(Throwable::class) fun address(): Address

    /** Signed prefixed-message. Bytes or encoded string as a UTF8-message */
    suspend fun signMessage(message: ByteArray): ByteArray

    /** Signs a transaction and returns the fully serialized, signed transaction
     * The transaction MUST be signed, and NO additional properties to be added.
     */
    @Throws(Throwable::class)
    suspend fun signTransaction(transaction: TransactionRequest): DataHexString

    /** Returns a new instance of the Signer, connected to provider. */
    fun connect(provider: Provider): Signer;

    /** Balance of network native currency */
    @Throws(Throwable::class) suspend fun getBalance(block: BlockTag): BigInt

    /** Count of all the sent transactions (nonce) */
    @Throws(Throwable::class)
    suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt

    /** Populates `from` if unspecified, and estimates the fee */
    @Throws(Throwable::class) abstract suspend
    fun estimateGas(transaction: Transaction): BigInt

    /** Populates "from" if unspecified, and calls with the transaction */
    @Throws(Throwable::class) suspend
    fun call(transaction: TransactionRequest, block: BlockTag = Latest): DataHexString

    /** Populates all fields, signs and sends it to the network */
    @Throws(Throwable::class) suspend
    fun sendTransaction(transaction: TransactionRequest): TransactionResponse

    @Throws(Throwable::class) suspend fun getChainId(): Unit

    @Throws(Throwable::class) abstract suspend fun gasPrice(): BigInt

    @Throws(Throwable::class) abstract suspend fun feeData(): FeeData

    @Throws(Throwable::class) abstract suspend
    fun resolveName(name: String): Address.HexString?
}
