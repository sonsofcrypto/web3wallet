package com.sonsofcrypto.web3lib_crypto


interface CryptoPrimitivesProvider {
    fun secureRand(size: Int): ByteArray
}

private var sharedProvider: CryptoPrimitivesProvider? = null

object Crypto : CryptoPrimitivesProvider {

    fun setProvider(provider: CryptoPrimitivesProvider) {
        if (sharedProvider == null) {
            sharedProvider = provider
        }
    }

    override fun secureRand(size: Int): ByteArray {
        if (sharedProvider == null) {
            throw Exception("Provider not set")
        }
        return sharedProvider!!.secureRand(size)
    }
}
