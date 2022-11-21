package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.secureRand
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import com.sonsofcrypto.web3walletcore.services.uuid.UUIDService

data class MnemonicNewInteractorData(
    val mnemonic: List<String>,
    val name: String,
    val passUnlockWithBio: Boolean,
    val iCloudSecretStorage: Boolean,
    val saltMnemonic: Boolean,
    val passwordType: KeyStoreItem.PasswordType,
)

interface MnemonicNewInteractor {
    @Throws(Exception::class)
    fun createKeyStoreItem(
        data: MnemonicNewInteractorData, password: String, salt: String
    ): KeyStoreItem
    fun generateMnemonic(): String
    fun generatePassword(): String
    fun pasteToClipboard(text: String)
    fun validationError(password: String, type: KeyStoreItem.PasswordType): String?
}

class DefaultMnemonicNewInteractor(
    private val keyStoreService: KeyStoreService,
    private val passwordService: PasswordService,
): MnemonicNewInteractor {

    override fun createKeyStoreItem(
        data: MnemonicNewInteractorData, password: String, salt: String
    ): KeyStoreItem {
        val worldList = WordList.fromLocaleString("en")
        val bip39 = Bip39(data.mnemonic, salt, worldList)
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
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

    override fun generateMnemonic(): String = Bip39.from().mnemonic.joinToString(" ")

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

    override fun generatePassword(): String = secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun validationError(password: String, type: KeyStoreItem.PasswordType): String? =
        passwordService.validationError(password, type)
}