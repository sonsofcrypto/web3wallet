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
        if (!Regex("(?=.{6,})").containsMatchIn(text))
            return Localized("validation.error.pin.min.length")
        if (text[0] == text[1])
            return Localized("validation.error.pin.weak")
        return null
    }

    fun passValidationError(text: String): String? {
        if (!Regex("(?=.{8,})").containsMatchIn(text))
            return Localized("validation.error.pass.min.length")
        if (!Regex("(?=.*[A-Z])").containsMatchIn(text))
            return Localized("validation.error.pass.min.capital")
        if (!Regex("(?=.*[a-z])").containsMatchIn(text))
            return Localized("validation.error.pass.min.lowercase")
        if (!Regex("(?=.*\\d)").containsMatchIn(text))
            return Localized("validation.error.pass.min.digit")
        return null
    }
}