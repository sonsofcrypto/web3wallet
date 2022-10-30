package com.sonsofcrypto.web3lib.abi

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.toHexString
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256
import io.ktor.utils.io.core.*
import kotlin.reflect.typeOf


// uint->uint256, int->int256, address->uint160, bool->uint8, bytes->hex32, function->bytes24 (function&address)
// string->dynamic(UTF-8), x§
class AbiEncode {

    companion object {
        fun encode(types: Array<String>, inputs: Array<Any>): ByteArray {
            if (types.count() != inputs.count()) {
                throw InputAndTypeNotEqualSizeException("`types` and `inputs` needs to be equal size")
            }
            var output = ByteArray(0)
            types.forEachIndexed { index, type ->
                val input = inputs[index]

                output += encode(type, input)
            }

            return output
        }
        fun encode (type: String, input: Any) : ByteArray {
            if (type == "string" && input is String) {
                return encode(input)
            }
            if (type == "address") {
                if (input is Address.HexString) {
                    return encode(input)
                }
                if (input is String) {
                    return encode(Address.HexString(input))
                }
            }

            if (type == "bool" && input is Boolean) {
                return encode(input)
            }

            if (type.startsWith("tuple")) {
                // TODO: Clean up this and use better regex to capture the different formats
                // tuple(string,int)
                // tuple(string data, int deadline)
                // tuple(uint deadline, bytes multicall)
                // A lot of possible variation here as it's strings
                val regex = Regex("tuple\\((.*)\\)")
                val regexComma = Regex("\\s*(.*)\\s*.*")
                val matches = regex.find(type)
                val tupleTypes = matches!!.groupValues[1].split(",").map {
                    regexComma.find(it)!!.groupValues[1].split(" ")[0]
                }

                return encode(tupleTypes.toTypedArray(), input as Array<Any>)
            }

            if (type in arrayOf("uint", "uint16", "uint160", "uint256", "int", "int16", "int160", "int256")) {
                if (input is BigInt)
                    return encode(input)
                return encode(BigInt.from(input.toString()))
            }

            throw UnsupportedABITypeException("Does not support type `${type}` as input type for encoding value `${input.toString()}`")
        }
        fun encode(input: Boolean): ByteArray {
            if (input)
                return leftPadZeros(byteArrayOf(1))
            else
                return leftPadZeros(byteArrayOf(0))
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
            return leftPadZeros(input.toByteArray())
        }

        fun encode(input: String): ByteArray {
            var output = ""
            for (entry in input.chunked(64)) {
                output += rightPadZeros(entry.toByteArray()).toHexString()
            }
            output = encode(input.toByteArray().size).toHexString() + output
            return output.hexStringToByteArray()
        }

        fun encode(input: Address): ByteArray {
            val _input = input.toHexString().removePrefix("0x")
            return ByteArray((64-_input.toByteArray().size)/2) + _input.hexStringToByteArray()
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

        fun leftPadZeros(input: ByteArray) : ByteArray {
            var hex = input.toHexString()
            while (hex.length < 64) {
                hex = "0" + hex
            }
            return hex.hexStringToByteArray()
        }
        fun rightPadZeros(input: ByteArray) : ByteArray {
            var hex = input.toHexString()
            while (hex.length < 64) {
                hex += "0"
            }
            return hex.hexStringToByteArray()

            //return input + ByteArray(32-input.toHexString().length/2)
        }
    }
}

class InputAndTypeNotEqualSizeException(message: String) : Exception(message)
class UnsupportedABITypeException(message: String) : Exception(message)