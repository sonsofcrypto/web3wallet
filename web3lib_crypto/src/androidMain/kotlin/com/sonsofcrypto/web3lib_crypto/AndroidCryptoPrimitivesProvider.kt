package com.sonsofcrypto.web3lib_crypto

import coreCrypto.*

/** Wrapper around coreCrypto functions */
class AndroidCryptoPrimitivesProvider : CryptoPrimitivesProvider {

    override fun secureRand(size: Int): ByteArray {
        return CoreCrypto.secureRand(size.toLong())
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

    override fun keccak256(data: ByteArray): ByteArray {
        return CoreCrypto.keccak256(data)

    }

    override fun keccak512(data: ByteArray): ByteArray {
        return CoreCrypto.keccak512(data)
    }

    private fun hashFnInt(hashFn: HashFn): Long {
        return when (hashFn) {
            HashFn.SHA256 -> CoreCrypto.HashFnSha256
            HashFn.SHA512 -> CoreCrypto.HashFnSha512
        }
    }
}