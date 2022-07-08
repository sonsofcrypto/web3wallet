package com.sonsofcrypto.web3lib_keystore

import kotlinx.serialization.Serializable

@Serializable
data class KeyStoreItem(
    val uuid: String,
    var name: String,
    var sortOrder: UInt,
    var type: Type,
    var passUnlockWithBio: Boolean = false,
    var iCloudSecretStorage: Boolean = false,
    var saltMnemonic: Boolean = false,
    var passwordType: PasswordType = PasswordType.BIO,
    /** Key is a derivation path eg m/44'/60'/0'/0/0 */
    var addresses: Map<String, String>,
) {
    @Serializable
    enum class Type {
        MNEMONIC, PRVKEY, PUBKEY, HARDWARE, MULTISIG,
    }

    @Serializable
    enum class PasswordType {
        PIN, PASS, BIO,
    }
}
