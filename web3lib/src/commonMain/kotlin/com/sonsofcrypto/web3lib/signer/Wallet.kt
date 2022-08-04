package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.AddressBytes
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.hexStringToByteArray

class Wallet: Signer {
    private val keyStoreItem: KeyStoreItem
    private val keyStoreService: KeyStoreService
    private var provider: Provider? = null

    constructor(
        keyStoreItem: KeyStoreItem,
        keyStoreService: KeyStoreService,
        provider: Provider? = null,
    ) {
        this.keyStoreItem = keyStoreItem
        this.keyStoreService = keyStoreService
        this.provider = provider
    }

    fun id(): String = keyStoreItem.uuid

    override fun provider(): Provider? = provider

    override fun connect(provider: Provider): Signer {
        this.provider = provider
        return this
    }

    fun network(): Network? = provider?.network

    @Throws(Throwable::class)
    override fun address(): Address {
        val path = keyStoreItem.derivationPath
        val hexStrAddress = keyStoreItem.addresses[path]
        if (hexStrAddress != null)
            return Address.HexString(hexStrAddress)
        throw Error.MissingAddressError(path, keyStoreItem.uuid)
    }

    override suspend fun signMessage(message: ByteArray): ByteArray {
        TODO("Not yet implemented")
    }

    override suspend fun signTransaction(transaction: TransactionRequest): DataHexString {
        TODO("Not yet implemented")
    }

    override suspend fun getBalance(block: BlockTag): BigInt {
        return provider!!.getBalance(address(), block)
    }

    @Throws(Throwable::class)
    override suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt {
        return provider!!.getTransactionCount(address, block)
    }

    override suspend fun estimateGas(transaction: Transaction): BigInt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun call(transaction: TransactionRequest, block: BlockTag): DataHexString {
        return provider!!.call(transaction, block)
    }

    override suspend fun sendTransaction(transaction: TransactionRequest): TransactionResponse {
        TODO("Transform to raw")
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
        return Wallet(keyStoreItem, keyStoreService, provider)
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
    }
}

