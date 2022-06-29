package com.sonsofcrypto.web3lib_crypto

import coreCrypto.*

/** Wrapper around coreCrypto functions */
class AndroidCryptoPrimitivesProvider : CryptoPrimitivesProvider {

    @Throws(Exception::class)
    override fun secureRand(size: Int): ByteArray {
        return CoreCrypto.secureRand(size.toLong())
    }

    override fun compressedPubKey(curve: Curve, prv: ByteArray): ByteArray {
        return CoreCrypto.compressedPubKey(curveInt(curve), prv)
    }

    override fun sha256(data: ByteArray): ByteArray {
        return CoreCrypto.hash(data, hashFnInt(HashFn.SHA256))
    }

    override fun sha512(data: ByteArray): ByteArray {
        return CoreCrypto.hash(data, hashFnInt(HashFn.SHA512))
    }

    override fun keccak256(data: ByteArray): ByteArray {
        return CoreCrypto.keccak256(data)
    }

    override fun keccak512(data: ByteArray): ByteArray {
        return CoreCrypto.keccak512(data)
    }

    override fun ripemd160(data: ByteArray): ByteArray {
        return CoreCrypto.hash(data, hashFnInt(HashFn.RIPEMD160))
    }

    override fun hmacSha512(key: ByteArray, data: ByteArray): ByteArray {
        return CoreCrypto.hmacSha512(key, data)
    }

    override fun pbkdf2(
        pswd: ByteArray, salt: ByteArray,
        iter: Int, keyLen: Int,
        hash: HashFn
    ): ByteArray {
        return CoreCrypto.pbkdf2(
            pswd, salt,
            iter.toLong(), keyLen.toLong(),
            hashFnInt(hash)
        )
    }

    override fun addPrvKeys(curve: Curve, key1: ByteArray, key2: ByteArray): ByteArray {
        return CoreCrypto.addPrivKeys(curveInt(curve), key1, key2)
    }

    override fun addPubKeys(curve: Curve, key1: ByteArray, key2: ByteArray): ByteArray {
        return CoreCrypto.addPubKeys(curveInt(curve), key1, key2)
    }

    override fun isBip44ValidPrv(curve: Curve, key: ByteArray): Boolean {
        return CoreCrypto.isBip44ValidPrv(curveInt(curve), key)
    }

    override fun isBip44ValidPub(curve: Curve, key: ByteArray): Boolean {
        return CoreCrypto.isBip44ValidPub(curveInt(curve), key)
    }

    private fun hashFnInt(hashFn: HashFn): Long {
        return when (hashFn) {
            HashFn.SHA256 -> CoreCrypto.HashFnSha256
            HashFn.SHA512 -> CoreCrypto.HashFnSha512
            HashFn.KECCAK256 -> CoreCrypto.HashFnKeccak256
            HashFn.KECCAK512 -> CoreCrypto.HashFnKeccak512
            HashFn.RIPEMD160 -> CoreCrypto.HashFnRipemd160
        }
    }

    private fun curveInt(curve: Curve): Long {
        return when (curve) {
            Curve.SECP256K1 -> CoreCrypto.CurveSecp256k1
        }
    }
}