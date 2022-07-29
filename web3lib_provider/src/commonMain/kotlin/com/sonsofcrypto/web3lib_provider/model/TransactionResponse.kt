package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.Address
import com.sonsofcrypto.web3lib_utils.BigInt
import kotlinx.serialization.json.JsonObject

interface TransactionResponse {
    val hash: String
    val blockNumber: UInt?
    val blockHash: String?
    val timestamp: Double?
    val confirmations: UInt
    val from: Address
    val raw: ByteArray?
    val gasLimit: BigInt?
    val gasPrice: BigInt?
}

