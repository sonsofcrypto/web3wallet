package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
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
    val passwordType: SignerStoreItem.PasswordType,
)

interface MnemonicNewInteractor {
    @Throws(Exception::class)
    fun createKeyStoreItem(
        data: MnemonicNewInteractorData, password: String, salt: String
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
): MnemonicNewInteractor {

    override fun createKeyStoreItem(
        data: MnemonicNewInteractorData, password: String, salt: String
    ): SignerStoreItem {
        val worldList = WordList.fromLocaleString("en")
        val bip39 = Bip39(data.mnemonic, salt, worldList)
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        val derivationPath = Network.ethereum().defaultDerivationPath()
        val extKey = bip44.deriveChildKey(derivationPath)
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
            addresses(bip44)
        )
        val secretStorage = SecretStorage.encryptDefault(
            signerStoreItem.uuid,
            extKey.key,
            password,
            Network.ethereum().address(extKey.xpub()).toHexString(true),
            bip39.mnemonic.joinToString(" "),
            bip39.worldList.localeString(),
            derivationPath
        )
        signerStoreService.add(signerStoreItem, password, secretStorage)
        return signerStoreItem
    }

    override fun generateMnemonic(): String = Bip39.from().mnemonic.joinToString(" ")

    @Throws(Error::class)
    private fun addresses(bip44: Bip44): Map<String, String> {
        val addresses: MutableMap<String, String> = mutableMapOf()
        NetworksService.supportedNetworks().forEach {
            val path = it.defaultDerivationPath()
            val xPub = bip44.deriveChildKey(path).xpub()
            addresses[path] = it.address(xPub).toHexString(true)
        }
        return addresses
    }

    override fun generatePassword(): String = secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun validationError(
        password: String,
        type: SignerStoreItem.PasswordType
    ): String? = passwordService.validationError(password, type)

    override fun keyStoreItemsCount(): Int = signerStoreService.items().count()
}