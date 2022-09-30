package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256
import io.ktor.utils.io.core.*

class AbiEncode {
    companion object {
        fun encode(input: Boolean): ByteArray {
            return ByteArray(31) + (if (input) 1 else 0).toByte()
        }
        fun encode(input: Int): ByteArray {
            return encode(BigInt.from(input))
        }

        fun encode(input: UInt): ByteArray {
            return encode(BigInt.from(input))
        }

        fun encode(input: Long): ByteArray {
            return encode(BigInt.from(input))
        }

        fun encode(input: BigInt): ByteArray {
            return ByteArray(32-input.toByteArray().size) + input.toByteArray()
        }

        fun encodeCallSignature(input: String) : ByteArray {
            return keccak256(input.toByteArray()).toHexString().substring(0,8).hexStringToByteArray();
        }
    }
}