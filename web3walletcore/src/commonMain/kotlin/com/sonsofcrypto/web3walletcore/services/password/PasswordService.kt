package com.sonsofcrypto.web3walletcore.services.password

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3walletcore.extensions.Localized

interface PasswordService {
    fun validationError(password: String, type: KeyStoreItem.PasswordType): String?
}

class DefaultPasswordService: PasswordService {

    override fun validationError(password: String, type: KeyStoreItem.PasswordType): String? =
        when (type) {
            KeyStoreItem.PasswordType.PIN -> pinValidationError(password)
            KeyStoreItem.PasswordType.PASS -> passValidationError(password)
            KeyStoreItem.PasswordType.BIO -> null
        }


    private fun pinValidationError(text: String): String? {
        if (!text.matches(Regex("(?=.{8,})")))
            return Localized("validation.error.pass.min.lenght")
        if (!text.matches(Regex("(?=.*[A-Z])")))
            return Localized("validation.error.pass.min.capital")
        if (!text.matches(Regex("(?=.*[a-z])")))
            return Localized("validation.error.pass.min.lowercase")
        if (!text.matches(Regex("(?=.*\\d)")))
            return Localized("validation.error.pass.min.digit")
        return null
    }

    fun passValidationError(text: String): String? {
        if (!text.matches(Regex("(?=.{8,})")))
            return Localized("validation.error.pass.min.lenght")
        if (!text.matches(Regex("(?=.*[A-Z])")))
            return Localized("validation.error.pass.min.capital")
        if (!text.matches(Regex("(?=.*[a-z])")))
            return Localized("validation.error.pass.min.lowercase")
        if (!text.matches(Regex("(?=.*\\d)")))
            return Localized("validation.error.pass.min.digit")
        return null
    }
}