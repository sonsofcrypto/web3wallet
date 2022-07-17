package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_core.Network

///** ProviderEvent */
//sealed class ProviderEvent() {
//
//    /** Emitted when network is setup */
//    sealed class Network(val network: Network) : ProviderEvent()
//
//    /** `BaseProvider` subclass does not support network detection */
//    object networkDetectionNotSupported : ProviderError("provider does not support network detection")
//    /** Unsuppored or invalid network */
//    object unsupportedNetwork : ProviderError("Unsupported or invalid network")
//}

interface ProviderEvent {}

interface ProviderEventNetwork {
    val network: Network
}

interface ProviderEventFilter: ProviderEvent {
    val address: AddressBytes
    val topics: List<Any?>
}

interface Filter: ProviderEventFilter {
    val fromBlock: UInt?
    val toBlock: UInt?
}

interface FilterByBlockHash: ProviderEventFilter {
    val blockHash: String
}

open class ForkProviderEvent(
    val expiry: UInt
) : ProviderEvent


class BlockForkProviderEvent : ForkProviderEvent {
    val blockHash: String

    constructor(blockHash: String, exp: UInt?) : super(expiry = exp ?: 0u) {
        this.blockHash = blockHash

        // TODO: Hex validation
        // if (!isHexString(blockHash, 32)) {
        //     logger.throwArgumentError("invalid blockHash", "blockHash", blockHash);
        // }
    }
}

class TransactionForkProviderEvent: ForkProviderEvent {
    val hash: String

    constructor(hash: String, exp: UInt?)  : super(expiry = exp ?: 0u) {
        this.hash = hash

        // TODO: Hex validation
        // if (!isHexString(hash, 32)) {
        //    logger.throwArgumentError("invalid transaction hash", "hash", hash);
        // }
    }
}

class TransactionOrderForkProviderEvent: ForkProviderEvent {
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
    fun handle(event: ProviderEvent)
}