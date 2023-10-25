package com.sonsofcrypto.web3walletcore.modules.authenticate

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService

interface AuthenticateInteractor {
    fun keyStoreItem(): SignerStoreItem?
    fun canUnlockWithBio(signerStoreItem: SignerStoreItem): Boolean
    fun unlockWithBiometrics(
        item: SignerStoreItem,
        title: String,
        handler: (AuthenticateData?, Error?) -> Unit
    )
    fun isValid(item: SignerStoreItem, password: String, salt: String): Boolean
}

class DefaultAuthenticateInteractor(
    private val signerStoreService: SignerStoreService
): AuthenticateInteractor {

    override fun keyStoreItem(): SignerStoreItem? = signerStoreService.selected

    override fun canUnlockWithBio(signerStoreItem: SignerStoreItem): Boolean =
        signerStoreItem.canUnlockWithBio() && signerStoreService.biometricsSupported()

    override fun unlockWithBiometrics(
        item: SignerStoreItem,
        title: String,
        handler: (AuthenticateData?, Error?) -> Unit
    ) {
        signerStoreService.biometricAuthenticate(title) { success: Boolean, error: Error? ->
            if (success) {
                val password = signerStoreService.password(item) ?: ""
                handler(AuthenticateData(password, ""), null)
            } else {
                handler(null, error ?: Error("Unknown error"))
            }
        }
    }

    override fun isValid(item: SignerStoreItem, password: String, salt: String): Boolean {
        return try {
            val secretStorage = signerStoreService.secretStorage(item, password) ?: return false
            secretStorage.decrypt(password)
            true
        } catch (error: Throwable) {
            false
        }
    }
}
