package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.*
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.extensions.zeroOut
import io.ktor.utils.io.core.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlin.time.Duration.Companion.seconds

/** Generic signer interface */
interface SignerIntf {
    /** Returns provider if connected */
    fun provider(): Provider?
    /** Returns a new instance of the Signer, connected to provider. */
    fun connect(provider: Provider): SignerIntf;
    /** Returns the checksum address */
    @Throws(Throwable::class)
    fun address(): Address

    /** Signed prefixed-message. Bytes or encoded string as a UTF8-message */
    suspend fun signMessage(message: ByteArray): ByteArray
    /** Signs a transaction and returns the fully serialized, signed transaction
     * The transaction MUST be signed, and NO additional properties to be added.*/
    @Throws(Throwable::class)
    suspend fun signTransaction(transaction: TransactionRequest): DataHexString

    /** Populates "from" if unspecified, and calls with the transaction */
    @Throws(Throwable::class)
    suspend fun call(transaction: TransactionRequest, block: BlockTag = BlockTag.Latest): DataHexString
    /** Populates all fields, signs and sends it to the network */
    @Throws(Throwable::class)
    suspend fun sendTransaction(transaction: TransactionRequest): TransactionResponse

    /** Balance of network native currency */
    @Throws(Throwable::class)
    suspend fun getBalance(block: BlockTag): BigInt
    /** Count of all the sent transactions (nonce) */
    @Throws(Throwable::class)
    suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt
    /** Populates `from` if unspecified, and estimates the fee */
    @Throws(Throwable::class)
    suspend fun estimateGas(transaction: TransactionRequest): BigInt
    /** Get transfer logs for ERC20 */
    @Throws(Throwable::class)
    suspend fun getTransferLogs(currency: Currency): List<Log>
    /** Get transaction receipt */
    suspend fun getTransactionReceipt(hash: String): TransactionReceipt

    /** Chain id of network */
    @Throws(Throwable::class)
    suspend fun getChainId(): Unit
    /** Gas price */
    @Throws(Throwable::class)
    suspend fun gasPrice(): BigInt
    /** FeeData */
    @Throws(Throwable::class)
    suspend fun feeData(): FeeData

    /** Resolves name using selected resolver */
    @Throws(Throwable::class)
    suspend fun resolveName(name: String): Address.HexString?
}

private val autoLockInterval = 5.seconds

class Wallet(
    private val signerStoreItem: SignerStoreItem,
    private val signerStoreService: SignerStoreService,
    private var provider: Provider? = null,
): SignerIntf {
    private var key: ByteArray? = null
    private var lockJob: Job? = null

    fun id(): String = signerStoreItem.uuid
    fun network(): Network? = provider?.network

    override fun provider(): Provider? = provider

    override fun connect(provider: Provider): SignerIntf {
        this.provider = provider
        return this
    }

    fun isUnlocked(): Boolean = (key != null)

    @Throws(Throwable::class)
    fun unlock(password: String, salt: String) {
        val secretStorage = signerStoreService.secretStorage(signerStoreItem, password)
            ?: throw Error.FailedToUnlockWallet

        val result = secretStorage.decrypt(password)

        if (result.mnemonic != null) {
            val wordList = WordList.fromLocaleString(result.mnemonicLocale)
            val bip39 = Bip39(result.mnemonic.split(" "), salt, wordList)
            val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
            key = bip44.deriveChildKey(signerStoreItem.derivationPath).key
        } else key = result.key

        lockJob = timerFlow(autoLockInterval, initialDelay = autoLockInterval)
            .onEach { lock() }
            .launchIn(CoroutineScope(bgDispatcher))
    }

    fun lock() {
        lockJob?.cancel()
        lockJob = null
        key?.zeroOut()
        key = null
    }

    @Throws(Throwable::class)
    override fun address(): Address {
        val path = signerStoreItem.derivationPath
        val hexStrAddress = signerStoreItem.addresses[path]
        if (hexStrAddress != null)
            return Address.HexString(hexStrAddress)
        throw Error.MissingAddressError(path, signerStoreItem.uuid)
    }

    override suspend fun signMessage(message: ByteArray): ByteArray {
        TODO("Not yet implemented")
    }

    override suspend fun signTransaction(transaction: TransactionRequest): DataHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun call(transaction: TransactionRequest, block: BlockTag): DataHexString {
        return provider!!.call(transaction, block)
    }

    @Throws(Throwable::class)
    override suspend fun sendTransaction(transaction: TransactionRequest): TransactionResponse {
        val provider = provider()
        val network = network()
        val address = address().toHexStringAddress()
        val key = key?.copyOf()

        if (provider == null || network == null || address == null)
            throw Error.ProviderConnectionError(this)

        if (key == null)
            throw Error.FailedToUnlockWallet

        val feeData = provider.feeData()
        val populatedTx = transaction.copy(
            from = address.toHexStringAddress(),
            nonce = getTransactionCount(address, block = BlockTag.Latest),
            chainId = network.chainId.toInt(),
            type = TransactionType.EIP1559,
            maxPriorityFeePerGas = feeData.maxPriorityFeePerGas,
            maxFeePerGas = feeData.maxFeePerGas,
        )
        val gasEstimate = provider.estimateGas(populatedTx)
        val populatedTxWithGas = populatedTx.copy(gasLimit = gasEstimate)
        val signature = sign(keccak256(populatedTxWithGas.encodeEIP1559()), key)
        val signedTransaction = populatedTxWithGas.copy(
            r = BigInt.from(signature.copyOfRange(0, 32)),
            s = BigInt.from(signature.copyOfRange(32, 64)),
            v = BigInt.from(signature[64].toInt()),
        )
        val signedRawTx = signedTransaction.encodeEIP1559()
        key.zeroOut()
        val nonce = signedTransaction.nonce!!
        val hash = provider.sendRawTransaction(DataHexString(signedRawTx))
        return TransactionResponse(
            hash = hash,
            blockNumber = null,
            blockHash = null,
            timestamp = null,
            confirmations = 0u,
            from = address,
            raw = signedRawTx,
            gasLimit = transaction.gasLimit,
            gasPrice = transaction.gasPrice,
        )
    }

    override suspend fun getBalance(block: BlockTag): BigInt {
        return provider!!.getBalance(address(), block)
    }

    @Throws(Throwable::class)
    override suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt {
        return provider!!.getTransactionCount(address, block)
    }

    override suspend fun estimateGas(transaction: TransactionRequest): BigInt {
        return provider!!.estimateGas(transaction)
    }

    @Throws(Throwable::class)
    override suspend fun getTransferLogs(currency: Currency): List<Log> {
        if (currency.type != Currency.Type.ERC20 || currency.address == null) {
            return listOf()
        }
        val hash = keccak256("Transfer(address,address,uint256)".toByteArray())
        val signature = DataHexString(hash)
        val address = address().toHexStringAddress().hexString
        val abiAddress = DataHexString(abiEncode(Address.HexString(address)))
        val fromLogs = provider?.getLogs(
            FilterRequest(
                BlockTag.Earliest,
                BlockTag.Latest,
                Address.HexString(currency.address),
                listOf(
                    Topic.TopicValue(signature),
                    Topic.TopicValue(abiAddress),
                    Topic.TopicValue(null),
                )
            )
        ) ?: listOf()
        val toLogs = provider?.getLogs(
            FilterRequest(
                BlockTag.Earliest,
                BlockTag.Latest,
                Address.HexString(currency.address),
                listOf(
                    Topic.TopicValue(signature),
                    Topic.TopicValue(null),
                    Topic.TopicValue(abiAddress),
                )
            )
        ) ?: listOf()

        return fromLogs.mapNotNull { it as? Log } +
            toLogs.mapNotNull { it as? Log }
    }

    override suspend fun getTransactionReceipt(hash: String): TransactionReceipt {
        return provider!!.getTransactionReceipt(hash)
    }

    override suspend fun getChainId() {
        provider!!.network.chainId
    }

    override suspend fun gasPrice(): BigInt {
        return provider!!.gasPrice()
    }

    override suspend fun feeData(): FeeData {
        return provider!!.feeData()
    }

    override suspend fun resolveName(name: String): Address.HexString? {
        return provider!!.resolveName(name)
    }

    fun copy(provider: Provider? = null): Wallet {
        return Wallet(signerStoreItem, signerStoreService, provider)
    }

    /** Exceptions */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {
        constructor(cause: Throwable) : this(null, cause)
        /** Missing Address for derivation path */
        data class MissingAddressError(val path: String, val itemId: String) :
            Error("Missing address $path for item $itemId")
        /** When calling methods that require provider while one is not connected */
        data class ProviderConnectionError(val wallet: Wallet) :
            Error("Provider not connected for ${wallet.id()}")
        /** Failed to unlock wallet */
        object FailedToUnlockWallet: Error("Failed to unlock wallet")
    }
}

