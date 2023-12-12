package com.sonsofcrypto.web3lib.services.keyStore

import kotlinx.serialization.Serializable
/**
 * `SignerStoreItem` contains metadata about `SecretStorage` items. Allows access
 * to non-sensitive data without authentication
 */
@Serializable
data class SignerStoreItem(
    /** Item UUID */
    val uuid: String,
    /** Custom user name of `SignerStoreItem` */
    val name: String,
    /** Sort order of an `SignerStoreItem` */
    val sortOrder: UInt,
    /** Type of signer [MNEMONIC, PRVKEY, PUBKEY, HARDWARE, MULTISIG] */
    val type: Type,
    /** Allow password access from keychain, biometric auth instead of typing in */
    val passUnlockWithBio: Boolean = false,
    /** Back up secret storage to cloud */
    val iCloudSecretStorage: Boolean = false,
    /** Custom salt for mnemonic */
    val saltMnemonic: Boolean = false,
    /** What type password was used [PIN, PASS, BIO,] */
    val passwordType: PasswordType = PasswordType.BIO,
    /** Account derivations path, coin_type (60) replaced with appropriate
     * value for each network */
    val derivationPath: String = "m/44'/60'/0'/0/0",
    /** Key is a derivation path eg m/44'/60'/0'/0/0, values are hex strings*/
    val addresses: Map<String, String>,
    /** Used for grouping items */
    val parentId: String? = null,
    /** weather item should be shown in UI */
    val hidden: Boolean? = false,
) {
    @Serializable
    enum class Type {
        MNEMONIC, PRVKEY, PUBKEY, HARDWARE, MULTISIG,
    }

    @Serializable
    enum class PasswordType {
        PIN, PASS, BIO,
    }

    // Can unlock item with biometrics only (No need for pass entry UI)
    fun canUnlockWithBio(): Boolean {
        if (saltMnemonic) {
            return false
        }
        return when {
            passUnlockWithBio || passwordType == PasswordType.BIO -> true
            else -> false
        }
    }

    fun primaryAddress(): String {
        // TODO: Handle signers that require salt to see the address
        return addresses[derivationPath] ?: "0xAuthenticateToSeeAddress"
    }

    fun isHidden(): Boolean = hidden ?: false
}
