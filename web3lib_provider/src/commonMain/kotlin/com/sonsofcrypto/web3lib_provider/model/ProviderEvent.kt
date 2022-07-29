package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_core.Network

interface ProviderEvent {

    companion object {
        fun network(network: Network): EventNetwork = object : EventNetwork {
            override val network: Network = network
        }
    }
}

interface EventNetwork: ProviderEvent {
    val network: Network
}

interface EventFilter: ProviderEvent {
    val address: AddressBytes
    val topics: List<Any?>
}

interface Filter: EventFilter {
    val fromBlock: UInt?
    val toBlock: UInt?
}

interface FilterByBlockHash: EventFilter {
    val blockHash: String
}

open class ForkEvent(
    val expiry: UInt
) : ProviderEvent


class BlockForkEvent : ForkEvent {
    val blockHash: String

    constructor(blockHash: String, exp: UInt?) : super(expiry = exp ?: 0u) {
        this.blockHash = blockHash

        // TODO: Hex validation
        // if (!isHexString(blockHash, 32)) {
        //     logger.throwArgumentError("invalid blockHash", "blockHash", blockHash);
        // }
    }
}

class TransactionForkEvent: ForkEvent {
    val hash: String

    constructor(hash: String, exp: UInt?)  : super(expiry = exp ?: 0u) {
        this.hash = hash

        // TODO: Hex validation
        // if (!isHexString(hash, 32)) {
        //    logger.throwArgumentError("invalid transaction hash", "hash", hash);
        // }
    }
}

class TransactionOrderForkEvent: ForkEvent {
    val beforeHash: String
    val afterHash: String

    constructor(beforeHash: String, afterHash: String, exp: UInt?)  : super(expiry = exp ?: 0u) {
        this.beforeHash = beforeHash
        this.afterHash = afterHash

        // TODO: Hex validation
        // if (!isHexString(beforeHash, 32)) {
        //     logger.throwArgumentError("invalid transaction hash", "beforeHash", beforeHash);
        // }
        // if (!isHexString(afterHash, 32)) {
        //     logger.throwArgumentError("invalid transaction hash", "afterHash", afterHash);
        // }
    }
}

interface ProviderListener {
    fun handle(providerEvent: ProviderEvent)
}