package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.abi.AbiEncode

class AbiNumber(override val type: String, override val value: Any) : AbiType {
    override fun encode(): ByteArray {
        return AbiEncode.encode(type, value)
    }

    override fun isDynamic(): Boolean {
        return false
    }

    companion object Companion : AbiValidatable {
        private val matchingTypes:Array<String> = arrayOf(
            "int", "int8", "int160", "int256",
            "uint", "uint8", "uint160", "uint256"
        )

        override fun isType(type: String): Boolean {
            return this.matchingTypes.contains(type)
        }
    }
}