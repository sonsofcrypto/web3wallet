package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService

interface MnemonicUpdateInteractor {
    @Throws(SecretStorage.Error::class)
    fun setup(keyStoreItem: KeyStoreItem, password: String, salt: String)
    fun mnemonic(): String
    fun pasteToClipboard(text: String)
    fun update(
        keyStoreItem: KeyStoreItem, name: String, iCloudSecretStorage: Boolean
    ): KeyStoreItem?
    fun delete(keyStoreItem: KeyStoreItem)
}

class DefaultMnemonicUpdateInteractor(
    private val keyStoreService: KeyStoreService,
): MnemonicUpdateInteractor {
    private var password: String = ""
    private var salt: String = ""
    private var mnemonic: String = ""

    @Throws(SecretStorage.Error::class)
    override fun setup(keyStoreItem: KeyStoreItem, password: String, salt: String) {
        this.password = password
        this.salt = salt
        val result = keyStoreService.secretStorage(keyStoreItem, password)?.decrypt(password)
        mnemonic = result?.mnemonic ?: ""
    }

    override fun mnemonic(): String = mnemonic

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun update(
        keyStoreItem: KeyStoreItem, name: String, iCloudSecretStorage: Boolean,
    ): KeyStoreItem? {
        val secretStorage = keyStoreService.secretStorage(keyStoreItem, password) ?: return null
        val keyStoreItem = KeyStoreItem(
            keyStoreItem.uuid,
            name,
            keyStoreItem.sortOrder,
            keyStoreItem.type,
            keyStoreItem.passUnlockWithBio,
            iCloudSecretStorage,
            keyStoreItem.saltMnemonic,
            keyStoreItem.passwordType,
            keyStoreItem.derivationPath,
            keyStoreItem.addresses,
        )
        keyStoreService.add(keyStoreItem, password, secretStorage)
        return keyStoreItem
    }

    override fun delete(keyStoreItem: KeyStoreItem) {
        if (keyStoreItem.uuid == keyStoreService.selected?.uuid) {
            keyStoreService.remove(keyStoreItem)
            keyStoreService.selected = keyStoreService.items().firstOrNull()
        } else {
            keyStoreService.remove(keyStoreItem)
        }
    }
}