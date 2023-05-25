package com.sonsofcrypto.web3lib.abi.types

interface AbiType {
    val type: String
    val value: Any

    fun encode(): ByteArray
    fun isDynamic(): Boolean
}

interface AbiValidatable {
    fun isType(type: String): Boolean
}