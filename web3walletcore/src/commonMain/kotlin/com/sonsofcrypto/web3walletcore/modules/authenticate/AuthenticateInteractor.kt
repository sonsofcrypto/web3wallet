package com.sonsofcrypto.web3walletcore.modules.authenticate

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService

interface AuthenticateInteractor {
    fun canUnlockWithBio(keyStoreItem: KeyStoreItem): Boolean
    fun unlockWithBiometrics(
        item: KeyStoreItem,
        title: String,
        handler: (AuthenticateData?, Error?) -> Unit
    )
    fun isValid(item: KeyStoreItem, password: String, salt: String): Boolean
}

class DefaultAuthenticateInteractor(
    private val keyStoreService: KeyStoreService
): AuthenticateInteractor {

    override fun canUnlockWithBio(keyStoreItem: KeyStoreItem): Boolean =
        keyStoreItem.canUnlockWithBio() && keyStoreService.biometricsSupported()

    override fun unlockWithBiometrics(
        item: KeyStoreItem,
        title: String,
        handler: (AuthenticateData?, Error?) -> Unit
    ) {
        keyStoreService.biometricsAuthenticate(title) { success: Boolean, error: Error? ->
            if (success) {
                val password = keyStoreService.password(item) ?: ""
                handler(AuthenticateData(password, ""), null)
            } else {
                handler(null, error ?: Error("Unknown error"))
            }
        }
    }

    override fun isValid(item: KeyStoreItem, password: String, salt: String): Boolean {
        return try {
            val secretStorage = keyStoreService.secretStorage(item, password) ?: return false
            secretStorage.decrypt(password)
            true
        } catch (error: Throwable) {
            false
        }
    }
}
