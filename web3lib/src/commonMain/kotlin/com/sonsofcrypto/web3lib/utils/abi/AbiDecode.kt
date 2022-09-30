package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import io.ktor.utils.io.core.*

class AbiDecode {
    companion object {
        fun decodeBoolean(input: String): Boolean {
            return input.substring(63,64).toInt() == 1
        }

        fun decodeInt(input: String): BigInt {
            return BigInt.from(input.replace("^[0]*".toRegex(), "").toInt(16))
        }


        fun decodeLong(input: String): BigInt {
            return BigInt.from(input.replace("^[0]*".toRegex(), "").toLong(16))
        }

        fun decodeUInt16(input: String): BigInt {
            return BigInt.from(input.replace("^[0]*".toRegex(), "").toUInt(16))
        }
    /*
        fun decodeCallSignature(input: String) : ByteArray {
            // TODO: Requires List of common hashes
        }
    */
    }
}