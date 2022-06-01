package com.sonsofcrypto.web3lib_bip39

import com.sonsofcrypto.web3lib_crypto.Crypto
import com.sonsofcrypto.web3lib_crypto.HashFn

private const val PBKDF2_ITER = 2048
private const val PBKDF2_KEYLEN = 64

class Bip39(val mnemonic: List<String>, val salt: String, val worldList: WordList) {

    /** Seed for mnemonic */
    @Throws(Exception::class) fun seed(): ByteArray {
        return Crypto.pbkdf2(
            mnemonic.joinToString(" ").encodeToByteArray(),
            ("mnemonic" + salt).encodeToByteArray(),
            PBKDF2_ITER,
            PBKDF2_KEYLEN,
            HashFn.SHA512
        )
    }

    /** Original entropy for mnemonic */
    fun entropy(): ByteArray {
        TODO("Implement")
    }

    /** Valid entropy sizes */
    enum class EntropySize(val value: Int) {
        ES128(128),
        ES160(160),
        ES192(192),
        ES224(224),
        ES256(256),
    }

    /** Exceptions */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** Failed to derive key from mnemonic */
        object FailedToDeriveKeyFromMnemonic : Error("Failed to derive key from mnemonic")

        /** Invalid word at index. */
        data class InvalidWord(val index: Int) : Error("Invalid word at index $index")
    }

    companion object {

        @Throws(Error::class) fun from(
            entropySize: EntropySize = EntropySize.ES128,
            salt: String = "",
            worldList: WordList = WordList.ENGLISH
        ): Bip39 {
            println("=== Throwing Failed")
            throw Error.FailedToDeriveKeyFromMnemonic
        }

        @Throws(Error::class) fun from(
            entropy: ByteArray,
            salt: String = "",
            worldList: WordList = WordList.ENGLISH
        ): Bip39 {
            println("=== Throwing Invalid words")
            throw Error.InvalidWord(2)
        }
    }
}
