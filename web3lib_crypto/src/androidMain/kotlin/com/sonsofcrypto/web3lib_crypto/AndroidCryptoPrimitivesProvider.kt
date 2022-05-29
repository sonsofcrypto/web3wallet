package com.sonsofcrypto.web3lib_crypto

import crypto.*

class AndroidCryptoPrimitivesProvider : CryptoPrimitivesProvider {

    override fun secureRand(size: Int): ByteArray {
        return crypto.Crypto.secureRand(size.toLong())
    }
}