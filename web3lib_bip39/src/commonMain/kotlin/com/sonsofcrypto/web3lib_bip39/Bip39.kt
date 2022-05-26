package com.sonsofcrypto.web3lib_bip39

class Bip39(mnemonic: List<String>, salt: String, worldList: WordList) {

    /** Seed for mnemonic */
    fun seed(): ByteArray {
        TODO("Implement")
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

        fun from(
            entropySize: EntropySize = EntropySize.ES128,
            salt: String = "",
            worldList: WordList = WordList.ENGLISH
        ): Bip39 {
            TODO("Implement")
        }

        fun from(
            entropy: ByteArray,
            salt: String = "",
            worldList: WordList = WordList.ENGLISH
        ): Bip39 {
            TODO("Implement")
        }
    }
}
