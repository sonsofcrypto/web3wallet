package com.sonsofcrypto.web3lib.abi.types

class AbiAddress(override val type: String, override val value: String) : AbiType {
    override fun encode(): ByteArray {
        TODO("Not yet implemented")
    }

    override fun isDynamic(): Boolean {
        TODO("Not yet implemented")
    }

    companion object : AbiValidatable {
        override fun isType(type: String): Boolean {
            return type == "address"
        }

    }
}