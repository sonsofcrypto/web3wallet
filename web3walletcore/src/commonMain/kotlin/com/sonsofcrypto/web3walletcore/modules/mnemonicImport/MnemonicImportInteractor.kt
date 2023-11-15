package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.services.uuid.UUIDService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey.Version.MAINNETPRV
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
import com.sonsofcrypto.web3lib.utils.defaultDerivationPath
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.secureRand
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicServiceError
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord
import com.sonsofcrypto.web3walletcore.services.password.PasswordService

data class MnemonicImportInteractorData(
    val mnemonic: List<String>,
    val name: String,
    val passUnlockWithBio: Boolean,
    val iCloudSecretStorage: Boolean,
    val saltMnemonic: Boolean,
    val passwordType: SignerStoreItem.PasswordType,
)

interface MnemonicImportInteractor {
    fun prefix(mnemonic: String, cursorLocation: Int): String
    fun potentialMnemonicWords(prefix: String?): List<String>
    fun findInvalidWords(mnemonic: String?): List<MnemonicWord>
    fun isValidPrefix(prefix: String): Boolean
    fun isMnemonicValid(mnemonic: String, salt: String?): Boolean
    @Throws(Exception::class)
    fun createKeyStoreItem(data: MnemonicImportInteractorData, password: String, salt: String): SignerStoreItem
    fun mnemonicError(mnemonic: List<String>, salt: String): MnemonicServiceError?
    fun generatePassword(): String
    fun pasteToClipboard(text: String)
    fun validationError(password: String, type: SignerStoreItem.PasswordType): String?
    fun keyStoreItemsCount(): Int
}

class DefaultMnemonicImportInteractor(
    private val signerStoreService: SignerStoreService,
    private val mnemonicService: MnemonicService,
    private val passwordService: PasswordService,
    private val addressService: AddressService,
): MnemonicImportInteractor {

    override fun prefix(mnemonic: String, cursorLocation: Int): String =
        mnemonicService.prefix(mnemonic, cursorLocation)

    override fun potentialMnemonicWords(prefix: String?): List<String> =
        mnemonicService.potentialMnemonicWords(prefix)

    override fun findInvalidWords(mnemonic: String?): List<MnemonicWord> =
        mnemonicService.findInvalidWords(mnemonic)

    override fun isValidPrefix(prefix: String): Boolean =
        mnemonicService.isValidPrefix(prefix)

    override fun isMnemonicValid(mnemonic: String, salt: String?): Boolean =
        mnemonicService.mnemonicError(mnemonic, salt) == null

    override fun createKeyStoreItem(data: MnemonicImportInteractorData, password: String, salt: String): SignerStoreItem {
        val worldList = WordList.fromLocaleString("en")
        val bip39 = Bip39(data.mnemonic, salt, worldList)
        val bip44 = Bip44(bip39.seed(), MAINNETPRV)
        val derivationPath = defaultDerivationPath()
        val extKey = bip44.deriveChildKey(derivationPath)
        val address = addressService.address(
            bip44.deriveChildKey(derivationPath).xpub()
        )
        val signerStoreItem = SignerStoreItem(
            UUIDService().uuidString(),
            data.name,
            (signerStoreService.items().lastOrNull()?.sortOrder ?: 0u) + 100u,
            SignerStoreItem.Type.MNEMONIC,
            data.passUnlockWithBio,
            data.iCloudSecretStorage,
            data.saltMnemonic,
            data.passwordType,
            derivationPath,
            mapOf(derivationPath to address)
        )
        val secretStorage = SecretStorage.encryptDefault(
            signerStoreItem.uuid,
            extKey.key,
            password,
            address,
            bip39.mnemonic.joinToString(" "),
            bip39.worldList.localeString(),
            derivationPath
        )
        signerStoreService.add(signerStoreItem, password, secretStorage)
        return signerStoreItem
    }

    override fun mnemonicError(
        mnemonic: List<String>,
        salt: String
    ): MnemonicServiceError? =
        mnemonicService.mnemonicError(mnemonic.joinToString(" "), salt)

    override fun generatePassword(): String = secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun validationError(password: String, type: SignerStoreItem.PasswordType): String? =
        passwordService.validationError(password, type)

    override fun keyStoreItemsCount(): Int = signerStoreService.items().count()
}