package com.sonsofcrypto.web3lib_crypto

import crypto.*

actual class CryptoUtils {

    actual fun secureRand(size: Int): ByteArray = Crypto.secureRand(size.toLong())
}