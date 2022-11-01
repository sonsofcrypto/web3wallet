package com.sonsofcrypto.web3walletcore.modules.authenticate

data class AuthenticateViewModel(
    val title: String,
    val password: String,
    val passType: PassType,
    val passwordPlaceholder: String,
    val salt: String,
    val saltPlaceholder: String,
    val needsPassword: Boolean,
    val needsSalt: Boolean,
) {
    enum class PassType { PIN, PASS }
}

