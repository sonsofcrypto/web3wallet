package com.sonsofcrypto.web3lib.abi.types

import com.sonsofcrypto.web3lib.abi.AbiEncode

class AbiTuple(override val type: String, override val value: Any) : AbiType {
    override fun encode(): ByteArray {
        return AbiEncode.encode(type, value)
    }

    override fun isDynamic(): Boolean {
        return true
        /*return AbiEncode.deconstructTuple(type).filter { it ->
            if (AbiString.isType(it) || AbiTuple.isType(it)) {
                return true
            }
            return false
        }.isNotEmpty()*/
    }

    companion object : AbiValidatable {
        override fun isType(type: String): Boolean {
            if (type.matches(Regex("tuple.*"))) {
                return true
            }
            return false
        }
    }
}