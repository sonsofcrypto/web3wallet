package com.sonsofcrypto.web3lib_core

class Wallet {

    companion object {

        fun fromEncrypted(
            json: String,
            pass: String,
            salt: String? = null
        ): Wallet {
            TODO("Implement")
        }

        fun fromMnemonic(
            mnemonic: String,
            pass: String,
            salt: String? = null
        ): Wallet {
            TODO("Implement")
        }
    }
}

