package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.MnemonicSignerConfig
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.secureRand
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService

data class MnemonicNewInteractorData(
    val mnemonic: List<String>,
    val name: String,
    val passUnlockWithBio: Boolean,
    val iCloudSecretStorage: Boolean,
    val saltMnemonic: Boolean,
    val passwordType: SignerStoreItem.PasswordType,
)

interface MnemonicNewInteractor {
    @Throws(Exception::class)
    fun createMnemonicSigner(
        config: MnemonicSignerConfig, password: String, salt: String
    ): SignerStoreItem
    fun generateMnemonic(): String
    fun generatePassword(): String
    fun pasteToClipboard(text: String)
    fun validationError(password: String, type: SignerStoreItem.PasswordType): String?
    fun keyStoreItemsCount(): Int
}

class DefaultMnemonicNewInteractor(
    private val signerStoreService: SignerStoreService,
    private val passwordService: PasswordService,
    private val addressService: AddressService,
): MnemonicNewInteractor {

    override fun createMnemonicSigner(
        config: MnemonicSignerConfig, password: String, salt: String
    ): SignerStoreItem {
        return signerStoreService.createMnemonicSigner(config, password, salt)
    }

    override fun generateMnemonic(): String = Bip39.from().mnemonic.joinToString(" ")

    override fun generatePassword(): String = secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun validationError(
        password: String,
        type: SignerStoreItem.PasswordType
    ): String? = passwordService.validationError(password, type)

    override fun keyStoreItemsCount(): Int = signerStoreService.items().count()
}