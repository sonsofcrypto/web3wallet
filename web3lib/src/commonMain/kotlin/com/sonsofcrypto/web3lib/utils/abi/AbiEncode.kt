package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.toHexString
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

        fun encode(input: String): ByteArray {
            return this.encode(input.toByteArray().size) + input.toByteArray() + ByteArray(32-input.toByteArray().size)
        }

        fun encode(input: Address): ByteArray {
            return ByteArray((64-input.toHexString().toByteArray().size)/2) +input.toHexString().hexStringToByteArray()
        }

        fun encode (input: Array<ByteArray>, includeCount: Boolean = false): ByteArray {
            val start = ArrayList<Int>()
            var output = ""
            for ((i, entry) in input.withIndex()) {
                start.add(i, output.length/2) // Set all start points to be prepended in the end
                output += entry.toHexString()
            }
            var arrayReference = "" // References to where in the following sequecnces that there's array entries.
            for (startIndex in start) {
                arrayReference += (encode(32*start.size+startIndex).toHexString())
            }
            output = arrayReference + output // Connect the references to array entries

            if (includeCount) {
                output = encode(input.size).toHexString() + output
            }
            return output.hexStringToByteArray()
        }

        fun encode (input: Array<BigInt>): ByteArray {
            var output = encode(input.size).toHexString()
            for (entry in input) {
                output += encode(entry).toHexString()
            }
            return output.hexStringToByteArray()
        }

        fun encodeCallSignature(input: String) : ByteArray {
            return keccak256(input.toByteArray()).toHexString().substring(0,8).hexStringToByteArray();
        }
    }
}