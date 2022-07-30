package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.utils.*
import com.sonsofcrypto.web3lib.provider.*
import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.AddressBytes

interface Signer {

    fun provider(): Provider?

    /** Returns the checksum address */
    suspend fun address(): AddressBytes

    /** Signed prefixed-message. Bytes or encoded string as a UTF8-message */
    suspend fun signMessage(message: ByteArray): ByteArray

    /** Signs a transaction and returns the fully serialized, signed transaction
     * The transaction MUST be signed, and NO additional properties to be added.
     */
    @Throws(Exception::class)
    suspend fun signTransaction(transaction: TransactionRequest): DataHexString

    /** Returns a new instance of the Signer, connected to provider. */
    fun connect(provider: Provider): Signer;

    /** Balance of network native currency */
    @Throws(Exception::class) suspend fun getBalance(block: BlockTag): BigInt

    /** Count of all the sent transactions (nonce) */
    @Throws(Exception::class)
    suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt

    /** Populates `from` if unspecified, and estimates the fee */
    @Throws(Throwable::class) abstract suspend
    fun estimateGas(transaction: Transaction): BigInt

    /** Populates "from" if unspecified, and calls with the transaction */
    @Throws(Exception::class) suspend
    fun call(transaction: TransactionRequest, block: UInt? = null): ByteArray

    /** Populates all fields, signs and sends it to the network */
    @Throws(Exception::class) suspend
    fun sendTransaction(transaction: TransactionRequest): TransactionResponse

    @Throws(Exception::class) suspend fun getChainId(): Unit

    @Throws(Throwable::class) abstract suspend fun gasPrice(): BigInt

    @Throws(Throwable::class) abstract suspend fun feeData(): FeeData

    @Throws(Throwable::class) abstract suspend
    fun resolveName(name: String): Address.HexString?
}
