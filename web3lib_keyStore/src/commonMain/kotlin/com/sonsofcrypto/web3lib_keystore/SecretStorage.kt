package com.sonsofcrypto.web3lib_keystore

import com.sonsofcrypto.web3lib_utils.*
import kotlinx.serialization.Serializable

private const val minDkLen: Long = 32

/**
 * Web3 secret storage, currently only supports scrypt for pdf
 * https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition#pbkdf2-sha-256
 */
@Serializable
data class SecretStorage(
    val crypto: Crypto,
    val id: String,
    val version: Int,
    val address: String? = null,
    val w3wParams: W3WParams? = null,
) {

    @Serializable
    data class Crypto(
        val ciphertext: String,
        val cipher: String,
        val cipherparams: CipherParams,
        val kdf: String,
        val kdfparams: KdfParams,
        val mac: String,
    ) {

        @Serializable
        data class CipherParams(
            val iv: String
        )

        @Serializable
        data class KdfParams(
            val n: Long? = null,
            val r: Long? = null,
            val p: Long? = null,
            val c: Long? = null,
            val dklen: Long = 32,
            val prf: String? = null,
            val salt: String = "",
        )
    }

    @Serializable
    data class W3WParams(
        val mnemonicLocal: String,
    )

    @Throws(Error::class)
    fun decrypt(password: String): ByteArray {
        val dkLen = crypto.kdfparams.dklen
        val cipherData = crypto.ciphertext.hexStringToByteArray()
        val dKey = scrypt(
            password.encodeToByteArray(),
            crypto.kdfparams.salt.hexStringToByteArray(),
            crypto.kdfparams.n ?: throw Error.FailedToLoadKDFParams,
            crypto.kdfparams.r ?: throw Error.FailedToLoadKDFParams,
            crypto.kdfparams.p ?: throw Error.FailedToLoadKDFParams,
            dkLen
        )
        val encKey = dKey.copyOfRange(0, (dkLen/2).toInt())
        val tailBytes = dKey.copyOfRange((dkLen/2).toInt(), dKey.size)

        if (keccak256(tailBytes + cipherData).toHexString() != crypto.mac) {
            throw Error.WrongPassword
        }
        return aesCTRXOR(encKey, cipherData, crypto.cipherparams.iv.hexStringToByteArray())
    }

    /** Exceptions */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        object DkLenTooShort : Error("dkLen lesser than $minDkLen")
        object FailedToLoadKDFParams : Error("Failed to load KDFParams")
        object WrongPassword : Error("Wrong password (mac failed)")
    }

    companion object {

        @Throws(Error::class)
        fun encypt(
            id: String,
            data: ByteArray,
            password: String,
            address: ByteArray? = null,
            n: Long = 262144, // 1 << 18
            p: Long = 1,
            r: Long = 8,
            dkLen: Long = 32,
            cipher: String = "aes-128-ctr",
            version: Int = 3,
            w3wParams: W3WParams? = null
        ): SecretStorage {
            if (dkLen < minDkLen) {
                throw Error.DkLenTooShort
            }
            val salt = secureRand(32)
            val iv = secureRand(16)
            val dKey = scrypt(password.encodeToByteArray(), salt, n, r, p, dkLen)
            val encKey = dKey.copyOfRange(0, (dkLen/2).toInt())
            val tailBytes = dKey.copyOfRange((dkLen/2).toInt(), dKey.size)
            val cipherData = aesCTRXOR(encKey, data, iv)
            return SecretStorage(
                Crypto(
                    cipherData.toHexString(),
                    cipher,
                    Crypto.CipherParams(iv.toHexString()),
                    "scrypt",
                    Crypto.KdfParams(n=n, r=r, p=p, dklen=dkLen, salt=salt.toHexString()),
                    keccak256(tailBytes + cipherData).toHexString(),
                ),
                id,
                version,
                address?.toHexString(),
                w3wParams
            )
        }
    }
}