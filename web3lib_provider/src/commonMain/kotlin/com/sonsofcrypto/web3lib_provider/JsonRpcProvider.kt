package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_core.Network
import com.sonsofcrypto.web3lib_utils.BigInt
import io.ktor.client.*
import kotlinx.coroutines.Deferred
import kotlin.time.Duration


open class JsonRpcProvider(
    val network: Network,
) : Provider() {

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

    override suspend fun storageAt(address: Address, position: BigInt, block: BlockTag): String {
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

    override fun on(event: Event, providerListener: Listener): Provider {
        TODO("Not yet implemented")
    }

    override fun once(event: Event, providerListener: Listener): Provider {
        TODO("Not yet implemented")
    }

    override fun emit(event: Event): Boolean {
        TODO("Not yet implemented")
    }

    override fun listenerCount(event: Event?): UInt {
        TODO("Not yet implemented")
    }

    override fun listeners(event: Event?): Array<Listener> {
        TODO("Not yet implemented")
    }

    override fun off(event: Event, providerListener: Listener?): Provider {
        TODO("Not yet implemented")
    }

    override fun removeAllListeners(event: Event?): Provider {
        TODO("Not yet implemented")
    }

    override suspend fun waitForTransaction(
        transactionHash: String,
        confirmations: UInt?,
        timeout: Double
    ): TransactionReceipt {
        TODO("Not yet implemented")
    }

    data class ConnectionInfo(
        val url: String,
        val headers: Map<String, String>,
        val user: String? = null,
        val password: String? = null,
        val allowInsecureAuthentication: Boolean = false,
        val allowGzip: Boolean = true,
        val throttleLimit: Int? = null,
        val throttleSlotInterval: Duration? = null,
        val throttleCallback: ((attempt: Int, url: String) -> Deferred<Boolean>)? = null,
        val skipFetchSetup: Boolean? = null,
        val errorPasThrough: Boolean? = null,
        val timeout: Duration? = null
    )
}