package com.sonsofcrypto.web3lib_crypto

enum class HashFn {
    SHA256, SHA512, KECCAK256, KECCAK512, RIPEMD160
}

enum class Curve {
    SECP256K1
}

interface CryptoPrimitivesProvider {
    /** Cryptographically secure source of randomnes */
    @Throws(Exception::class)
    fun secureRand(size: Int): ByteArray

    /** Returns compressed pub key bytes for `prv` key byte on given `curve`  */
    fun compressedPubKey(curve: Curve, prv: ByteArray): ByteArray

    /** Hash functions*/
    fun sha256(data: ByteArray): ByteArray
    fun sha512(data: ByteArray): ByteArray
    fun keccak256(data: ByteArray): ByteArray
    fun keccak512(data: ByteArray): ByteArray
    fun ripemd160(data: ByteArray): ByteArray
    fun hmacSha512(key: ByteArray, data: ByteArray): ByteArray
    fun pbkdf2(
        pswd: ByteArray, salt: ByteArray,
        iter: Int, keyLen: Int,
        hash: HashFn
    ): ByteArray

    /** Utilities */
    fun addPrvKeys(curve: Curve, key1: ByteArray, key2: ByteArray): ByteArray
    fun addPubKeys(curve: Curve, key1: ByteArray, key2: ByteArray): ByteArray

    fun isBip44ValidPrv(curve: Curve, key: ByteArray): Boolean
    fun isBip44ValidPub(curve: Curve, key: ByteArray): Boolean
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

    override fun compressedPubKey(curve: Curve, prv: ByteArray): ByteArray {
        return sharedProvider!!.compressedPubKey(curve, prv)
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

    override fun ripemd160(data: ByteArray): ByteArray {
        return sharedProvider!!.ripemd160(data)
    }

    override fun hmacSha512(key: ByteArray, data: ByteArray): ByteArray {
        return sharedProvider!!.hmacSha512(key, data)
    }

    override fun pbkdf2(
        pswd: ByteArray, salt: ByteArray,
        iter: Int, keyLen: Int,
        hash: HashFn
    ): ByteArray {
        return sharedProvider!!.pbkdf2(pswd, salt, iter, keyLen, hash)
    }

    override fun addPrvKeys(curve: Curve, key1: ByteArray, key2: ByteArray): ByteArray {
        return sharedProvider!!.addPrvKeys(curve, key1, key2)
    }

    override fun addPubKeys(curve: Curve, key1: ByteArray, key2: ByteArray): ByteArray {
        return sharedProvider!!.addPubKeys(curve, key1, key2)
    }

    override fun isBip44ValidPrv(curve: Curve, key: ByteArray): Boolean {
        return sharedProvider!!.isBip44ValidPrv(curve, key)
    }

    override fun isBip44ValidPub(curve: Curve, key: ByteArray): Boolean {
        return sharedProvider!!.isBip44ValidPub(curve, key)
    }
}
