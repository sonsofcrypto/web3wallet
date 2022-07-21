package com.sonsofcrypto.web3lib_provider

import com.sonsofcrypto.web3lib_core.AddressBytes

interface Log {
    val blockNumber: UInt
    val blockHash: String
    val transactionIndex: UInt

    val removed: Boolean

    val address: AddressBytes
    val data: ByteArray

    val topics: Array<String>

    val transactionHash: String
    val logIndex: UInt
}