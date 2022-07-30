package com.sonsofcrypto.web3lib.provider

import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import kotlinx.serialization.json.JsonObject

open class ProviderBase(override val network: Network): Provider() {

    @Throws(Throwable::class)
    override suspend fun blockNumber(): BigInt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun gasPrice(): BigInt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun sendRawTransaction(transaction: DataHexString): DataHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getBalance(address: Address, block: BlockTag): BigInt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getStorageAt(
        address: Address,
        position: ULong,
        block: BlockTag
    ): DataHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getTransactionCount(address: Address, block: BlockTag): BigInt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getCode(address: Address, block: BlockTag): DataHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun call(transaction: TransactionRequest, block: BlockTag): DataHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun estimateGas(transaction: Transaction): BigInt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun feeData(): FeeData {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getBlockTransactionCount(block: BlockTag): ULong {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getUncleCount(block: BlockTag): ULong {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getBlock(block: BlockTag, full: Boolean): Block {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getTransaction(hash: DataHexString): Transaction {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getTransaction(block: BlockTag, index: BigInt): Transaction {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getTransactionReceipt(hash: String): TransactionReceipt {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getUncleBlock(block: BlockTag, index: BigInt): Block {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getLogs(filterRequest: FilterRequest): List<Any> {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun newFilter(filterRequest: FilterRequest): QuantityHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun newBlockFilter(): QuantityHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun newPendingTransactionFilter(): QuantityHexString {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getFilterChanges(id: QuantityHexString): JsonObject {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun getFilterLogs(id: QuantityHexString): JsonObject {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun uninstallFilter(id: QuantityHexString): Boolean {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun resolveName(name: String): Address.HexString? {
        TODO("Not yet implemented")
    }

    @Throws(Throwable::class)
    override suspend fun lookupAddress(address: Address.HexString): String? {
        TODO("Not yet implemented")
    }

    override fun on(providerEvent: ProviderEvent, providerListener: ProviderListener): Provider {
        TODO("Not yet implemented")
    }

    override fun once(providerEvent: ProviderEvent, providerListener: ProviderListener): Provider {
        TODO("Not yet implemented")
    }

    override fun emit(providerEvent: ProviderEvent): Boolean {
        TODO("Not yet implemented")
    }

    override fun listenerCount(providerEvent: ProviderEvent?): UInt {
        TODO("Not yet implemented")
    }

    override fun listeners(providerEvent: ProviderEvent?): Array<ProviderListener> {
        TODO("Not yet implemented")
    }

    override fun off(providerEvent: ProviderEvent, providerListener: ProviderListener?): Provider {
        TODO("Not yet implemented")
    }

    override fun removeAllListeners(providerEvent: ProviderEvent?): Provider {
        TODO("Not yet implemented")
    }
}