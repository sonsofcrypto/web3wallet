package com.sonsofcrypto.web3lib_crypto

enum class HashFn {
    SHA256, SHA512
}

interface CryptoPrimitivesProvider {
    @Throws(Exception::class)
    fun secureRand(size: Int): ByteArray
    fun pbkdf2(
        pswd: ByteArray, salt: ByteArray,
        iter: Int, keyLen: Int,
        hash: HashFn
    ): ByteArray
    fun sha256(data: ByteArray): ByteArray
    fun sha512(data: ByteArray): ByteArray
    fun keccak256(data: ByteArray): ByteArray
    fun keccak512(data: ByteArray): ByteArray
    fun hmacSha512(key: ByteArray, data: ByteArray): ByteArray
}

private var sharedProvider: CryptoPrimitivesProvider? = null

object Crypto : CryptoPrimitivesProvider {

    fun setProvider(provider: CryptoPrimitivesProvider) {
        if (sharedProvider == null) {
            sharedProvider = provider
        }
    }

    @Throws(Exception::class)
    override fun secureRand(size: Int): ByteArray {
        return sharedProvider!!.secureRand(size)
    }

    override fun pbkdf2(
        pswd: ByteArray, salt: ByteArray,
        iter: Int, keyLen: Int,
        hash: HashFn
    ): ByteArray {
        return sharedProvider!!.pbkdf2(pswd, salt, iter, keyLen, hash)
    }

    override fun sha256(data: ByteArray): ByteArray {
        return sharedProvider!!.sha256(data)
    }

    override fun sha512(data: ByteArray): ByteArray {
        return sharedProvider!!.sha512(data)
    }

    override fun keccak256(data: ByteArray): ByteArray {
        return sharedProvider!!.keccak256(data)
    }

    override fun keccak512(data: ByteArray): ByteArray {
        return sharedProvider!!.keccak512(data)
    }

    override fun hmacSha512(key: ByteArray, data: ByteArray): ByteArray {
        return sharedProvider!!.hmacSha512(key, data)
    }
}
