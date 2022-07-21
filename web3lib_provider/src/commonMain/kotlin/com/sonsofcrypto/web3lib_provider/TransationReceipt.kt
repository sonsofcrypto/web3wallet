package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.AddressBytes
import com.sonsofcrypto.web3lib_utils.BigInt

interface TransactionReceipt {
    val to: AddressBytes
    val from: AddressBytes
    val contractAddress: AddressBytes
    val transactionIndex: UInt
    val root: String
    val gasUsed: BigInt
    val logsBloom: String
    val blockHash: String
    val transactionHash: String
    val logs: Array<Log>
    val blockNumber: UInt
    val confirmations: UInt
    val cumulativeGasUsed: BigInt
    val effectiveGasPrice: BigInt
    val byzantium: Boolean
    val type: TransactionType
    val status: UInt?
}