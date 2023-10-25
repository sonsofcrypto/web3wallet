package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService

interface MnemonicUpdateInteractor {
    @Throws(SecretStorage.Error::class)
    fun setup(signerStoreItem: SignerStoreItem, password: String, salt: String)
    fun mnemonic(): String
    fun pasteToClipboard(text: String)
    fun update(
        signerStoreItem: SignerStoreItem, name: String, iCloudSecretStorage: Boolean
    ): SignerStoreItem?
    fun delete(signerStoreItem: SignerStoreItem)
}

class DefaultMnemonicUpdateInteractor(
    private val signerStoreService: SignerStoreService,
): MnemonicUpdateInteractor {
    private var password: String = ""
    private var salt: String = ""
    private var mnemonic: String = ""

    @Throws(SecretStorage.Error::class)
    override fun setup(signerStoreItem: SignerStoreItem, password: String, salt: String) {
        this.password = password
        this.salt = salt
        val result = signerStoreService.secretStorage(signerStoreItem, password)?.decrypt(password)
        mnemonic = result?.mnemonic ?: ""
    }

    override fun mnemonic(): String = mnemonic

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun update(
        signerStoreItem: SignerStoreItem, name: String, iCloudSecretStorage: Boolean,
    ): SignerStoreItem? {
        val secretStorage = signerStoreService.secretStorage(signerStoreItem, password) ?: return null
        val item = SignerStoreItem(
            signerStoreItem.uuid,
            name,
            signerStoreItem.sortOrder,
            signerStoreItem.type,
            signerStoreItem.passUnlockWithBio,
            iCloudSecretStorage,
            signerStoreItem.saltMnemonic,
            signerStoreItem.passwordType,
            signerStoreItem.derivationPath,
            signerStoreItem.addresses,
        )
        signerStoreService.add(item, password, secretStorage)
        return item
    }

    override fun delete(signerStoreItem: SignerStoreItem) {
        if (signerStoreItem.uuid == signerStoreService.selected?.uuid) {
            signerStoreService.remove(signerStoreItem)
            signerStoreService.selected = signerStoreService.items().firstOrNull()
        } else {
            signerStoreService.remove(signerStoreItem)
        }
    }
}