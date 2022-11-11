package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.abi.AbiEncode

interface AbiType {
    val type: String
    val value: Any

    fun encode(): ByteArray
    fun isDynamic(): Boolean
}

interface AbiValidatable {
    fun isType(type: String): Boolean
}