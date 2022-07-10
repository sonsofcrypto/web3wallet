package com.sonsofcrypto.web3lib_core

import com.sonsofcrypto.web3lib_utils.*

private const val PBKDF2_ITER = 2048
private const val PBKDF2_KEYLEN = 64

/** Encapsulates bip39 standard functions */
class Bip39(val mnemonic: List<String>, val salt: String, val worldList: WordList) {

    /** Seed for mnemonic */
    @Throws(Exception::class) fun seed(): ByteArray {
        return pbkdf2(
            mnemonic.joinToString(" ").encodeToByteArray(),
            ("mnemonic" + salt).encodeToByteArray(),
            PBKDF2_ITER,
            PBKDF2_KEYLEN,
            HashFn.SHA512
        )
    }

    /** Original entropy for mnemonic */
    fun entropy(): ByteArray {
        if (!isValidWordsSize(mnemonic.size))
            throw Error.InvalidMnemonicSize(mnemonic.size)

        val indexes = mnemonic.map { worldList.indexOf(it) }
        val bitArray = BooleanArray(mnemonic.size * 11)

        mnemonic
            .map { worldList.indexOf(it) }
            .withIndex()
            .forEach { (idx, wordIdx) ->
            for (bit in 0..10)
                bitArray[idx * 11 + bit] = wordIdx and (1 shl (10 - bit)) != 0
        }

        return bitArray.copyOfRange(0, bitArray.size - (bitArray.size / 33))
            .toByteArray()
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

        /** Entropy size does not math bip39 standard */
        data class InvalidEntropySize(val size: Int) : Error("Entropy size $size does not math bip39 standard")

        /** Mnemonic size does not math bip39 standard */
        data class InvalidMnemonicSize(val size: Int) : Error("Mnemonic size $size does not math bip39 standard")

        /** Failed to generate cryptographically secure randomness */
        object SecureRandomness : Error("Failed to generate cryptographically secure randomness")

    }

    companion object {

        @Throws(Error::class) fun from(
            entropySize: EntropySize = EntropySize.ES128,
            salt: String = "",
            worldList: WordList = WordList.ENGLISH
        ): Bip39 {
            try {
                val entropy = secureRand(entropySize.value / 8)
                return from(entropy, salt, worldList)
            } catch (e: Exception) {
                println("Exception secureRand $e")
                throw Error.SecureRandomness
            }
        }

        @Throws(Error::class) fun from(
            entropy: ByteArray,
            salt: String = "",
            worldList: WordList = WordList.ENGLISH
        ): Bip39 {
            if (!isValidEntropySize(entropy.size))
                throw Error.InvalidEntropySize(entropy.size)

            val hashBitArray = sha256(entropy).toBitArray()
            val entropyBitArray = entropy.toBitArray()
            val checkSum = hashBitArray.copyOfRange(0, entropy.size / 4 )
            val checkSumEntropy = entropyBitArray + checkSum
            var words: MutableList<String> = mutableListOf()

            for (i in 0 until checkSumEntropy.size / 11) {
                var idx = 0
                for (j in 0..10) {
                    idx = idx shl 1
                    if (checkSumEntropy[i * 11 + j])
                        idx = idx or 0x01
                }
                words.add(worldList.word(idx))
            }

            return Bip39(words, salt, worldList)
        }

        fun isValidWordsSize(size: Int): Boolean = listOf(12, 15, 18, 21, 24)
            .contains(size)

        private fun isValidEntropySize(size: Int): Boolean = EntropySize.values()
            .map { it.value / 8 }
            .contains(size)
    }
}
