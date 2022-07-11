package com.sonsofcrypto.web3lib_utils

import CoreCrypto.*

/** Cryptographically secure source of randomnes */
@Throws(Exception::class)
actual fun secureRand(size: Int): ByteArray {
    return CoreCryptoSecureRandFatal(size.toLong())!!.toByteArray()
}
@Throws(Exception::class)
actual fun aesCTRXOR(key: ByteArray, inText: ByteArray, iv: ByteArray): ByteArray {
    val result: ByteArray = CoreCryptoAESCTRXOREmptyOnError(
        key.toDataFull(),
        inText.toDataFull(),
        iv.toDataFull()
    )!!.toByteArray()
    if (result.isEmpty()) {
        throw Exception("aesCTRXOR failed")
    }
    return result
}

@Throws(Exception::class)
actual fun aesCBCDecrypt(key: ByteArray, cipherText: ByteArray, iv: ByteArray): ByteArray {
    val result: ByteArray = CoreCryptoAESCBCDecryptEmptyOnError(
        key.toDataFull(),
        cipherText.toDataFull(),
        iv.toDataFull()
    )!!.toByteArray()
    if (result.isEmpty()) {
        throw Exception("aesCBCDecrypt failed")
    }
    return result
}