package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey.Version.MAINNETPRV
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.secureRand
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicServiceError
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import com.sonsofcrypto.web3walletcore.services.uuid.UUIDService

data class MnemonicImportInteractorData(
    val mnemonic: List<String>,
    val name: String,
    val passUnlockWithBio: Boolean,
    val iCloudSecretStorage: Boolean,
    val saltMnemonic: Boolean,
    val passwordType: KeyStoreItem.PasswordType,
)

interface MnemonicImportInteractor {
    fun potentialMnemonicWords(prefix: String?): List<String>
    fun findInvalidWords(mnemonic: String?): List<MnemonicWord>
    fun isValidPrefix(prefix: String): Boolean
    fun isMnemonicValid(mnemonic: String, salt: String?): Boolean
    @Throws(Exception::class)
    fun createKeyStoreItem(data: MnemonicImportInteractorData, password: String, salt: String): KeyStoreItem
    fun mnemonicError(mnemonic: List<String>, salt: String): MnemonicServiceError?
    fun generatePassword(): String
    fun pasteToClipboard(text: String)
    fun validationError(password: String, type: KeyStoreItem.PasswordType): String?
    fun keyStoreItemsCount(): Int
}

class DefaultMnemonicImportInteractor(
    private val keyStoreService: KeyStoreService,
    private val mnemonicService: MnemonicService,
    private val passwordService: PasswordService,
): MnemonicImportInteractor {

    override fun potentialMnemonicWords(prefix: String?): List<String> =
        mnemonicService.potentialMnemonicWords(prefix)

    override fun findInvalidWords(mnemonic: String?): List<MnemonicWord> =
        mnemonicService.findInvalidWords(mnemonic)

    override fun isValidPrefix(prefix: String): Boolean =
        mnemonicService.isValidPrefix(prefix)

    override fun isMnemonicValid(mnemonic: String, salt: String?): Boolean =
        mnemonicService.mnemonicError(mnemonic, salt) == null

    override fun createKeyStoreItem(data: MnemonicImportInteractorData, password: String, salt: String): KeyStoreItem {
        val worldList = WordList.fromLocaleString("en")
        val bip39 = Bip39(data.mnemonic, salt, worldList)
        val bip44 = Bip44(bip39.seed(), MAINNETPRV)
        val derivationPath = Network.ethereum().defaultDerivationPath()
        val extKey = bip44.deriveChildKey(derivationPath)
        val keyStoreItem = KeyStoreItem(
            UUIDService().uuidString(),
            data.name,
            (keyStoreService.items().lastOrNull()?.sortOrder ?: 0u) + 100u,
            KeyStoreItem.Type.MNEMONIC,
            data.passUnlockWithBio,
            data.iCloudSecretStorage,
            data.saltMnemonic,
            data.passwordType,
            derivationPath,
            addresses(bip44)
        )
        val secretStorage = SecretStorage.encryptDefault(
            keyStoreItem.uuid,
            extKey.key,
            password,
            Network.ethereum().address(extKey.xpub()).toHexString(true),
            bip39.mnemonic.joinToString(" "),
            bip39.worldList.localeString(),
            derivationPath
        )
        keyStoreService.add(keyStoreItem, password, secretStorage)
        return keyStoreItem
    }

    @Throws(Error::class)
    private fun addresses(bip44: Bip44): Map<String, String> {
        val addresses: MutableMap<String, String> = emptyMap<String, String>().toMutableMap()
        NetworksService.supportedNetworks().forEach {
            val path = it.defaultDerivationPath()
            val xPub = bip44.deriveChildKey(path).xpub()
            addresses[path] = it.address(xPub).toHexString(true)
        }
        return addresses
    }

    override fun mnemonicError(mnemonic: List<String>, salt: String): MnemonicServiceError? =
        mnemonicService.mnemonicError(mnemonic.joinToString(" "), salt)

    override fun generatePassword(): String = secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun validationError(password: String, type: KeyStoreItem.PasswordType): String? =
        passwordService.validationError(password, type)

    override fun keyStoreItemsCount(): Int = keyStoreService.items().count()
}