package com.sonsofcrypto.web3lib.utils

import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray

//import coreCrypto.CoreCrypto

/** Hash functions*/

var returnVal: ByteArray = ByteArray(10)

// Mock return value of crypto functions
fun setReturnValue(input: String) {
    returnVal = input.hexStringToByteArray()
}

fun sha256(data: ByteArray): ByteArray {
    return returnVal
}

fun sha512(data: ByteArray): ByteArray {
    return returnVal
}

fun keccak256(data: ByteArray): ByteArray {
    return returnVal
}

fun keccak512(data: ByteArray): ByteArray {
    return returnVal
}

fun ripemd160(data: ByteArray): ByteArray {
    return returnVal
}

fun hmacSha512(key: ByteArray, data: ByteArray): ByteArray {
    return returnVal
}

fun hashFnInt(hashFn: HashFn): Long {
    return when (hashFn) {
        HashFn.SHA256 -> 0
        HashFn.SHA512 -> 1
        HashFn.KECCAK256 -> 2
        HashFn.KECCAK512 -> 3
        HashFn.RIPEMD160 -> 4
    }
}