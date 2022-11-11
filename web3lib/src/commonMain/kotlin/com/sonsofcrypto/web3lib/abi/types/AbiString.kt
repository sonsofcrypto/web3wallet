package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.abi.AbiEncode

class AbiString(override val type: String, override val value: String) : AbiType {
    override fun encode(): ByteArray {
        return AbiEncode.encode("string", value)
    }

    override fun isDynamic(): Boolean {
        return true
    }

    companion object : AbiValidatable {
        private val matchingTypes:Array<String> = arrayOf(
            "string"
        )
        override fun isType(type: String): Boolean {
            return this.matchingTypes.contains(type)
        }
    }
}