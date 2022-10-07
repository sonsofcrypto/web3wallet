package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray

class AbiDecode {
    companion object {
        fun decodeBoolean(input: String): Boolean {
            return input.substring(63,64).toInt() == 1
        }

        fun decodeInt(input: String): BigInt {
            return decodeByteArray(input.hexStringToByteArray())
        }

        fun decodeByteArray(input: ByteArray): BigInt {
            return BigInt.from(input)
        }

        fun decodeAddress(input: String): Address {
            return Address.HexString(input.replace("^[0]*".toRegex(), ""))
        }
    /*
        fun decodeCallSignature(input: String) : ByteArray {
            // TODO: Requires List of common hashes
        }
    */
    }
}