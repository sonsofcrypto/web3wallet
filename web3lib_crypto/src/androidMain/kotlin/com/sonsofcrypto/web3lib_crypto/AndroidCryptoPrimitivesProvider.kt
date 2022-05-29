package com.sonsofcrypto.web3lib_crypto

import coreCrypto.*

class AndroidCryptoPrimitivesProvider : CryptoPrimitivesProvider {

    override fun secureRand(size: Int): ByteArray {
        return coreCrypto.CoreCrypto.secureRand(size.toLong())
    }
}