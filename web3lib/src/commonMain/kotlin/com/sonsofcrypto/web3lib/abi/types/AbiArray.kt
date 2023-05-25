package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.abi.AbiEncode

class AbiArray(override val type: String, override val value: Array<*>) : AbiType {
    override fun encode(): ByteArray {
        return AbiEncode.encode(type, value)
    }

    override fun isDynamic(): Boolean {
        return type.matches(Regex("string.*")) || type.matches(Regex("tuple.*"))
    }

    companion object Companion : AbiValidatable {
        override fun isType(type: String): Boolean {
            return type.matches(Regex(".*\\[\\]")) && ! type.matches(Regex("tuple.*")) // also check bytes[31] etc
        }
    }
}