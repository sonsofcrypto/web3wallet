package com.sonsofcrypto.web3lib_utils

import coreCrypto.*

/** Cryptographically secure source of randomnes */
@Throws(Exception::class)
actual fun secureRand(size: Int): ByteArray = CoreCrypto.secureRand(size.toLong())

@Throws(Exception::class)
actual fun aesCTRXOR(key: ByteArray, inText: ByteArray, iv: ByteArray): ByteArray {
    return CoreCrypto.aesctrxor(key, inText, iv)
}

@Throws(Exception::class)
actual fun aesCBCDecrypt(key: ByteArray, cipherText: ByteArray, iv: ByteArray): ByteArray {
    return CoreCrypto.aescbcDecrypt(key, cipherText, iv)
}