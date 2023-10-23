package com.sonsofcrypto.web3lib.services.keyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.uuid.UUIDService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

private val selectedKey = "selected_uuid"

data class MnemonicSignerConfig(
    val mnemonic: List<String>,
    val name: String,
    val passUnlockWithBio: Boolean,
    val iCloudSecretStorage: Boolean,
    val saltMnemonic: Boolean,
    val passwordType: SignerStoreItem.PasswordType,
    val wordList: WordList = WordList.fromLocaleString("en"),
)

/** Handles management of `SignerStoreItem`s and `SecretStorage` items. */
interface SignerStoreService {
    /** Latest selected `KeyStoreItem` (persists between launches) */
    var selected: SignerStoreItem?
    /** Create `SignerStoreItem` & `SecretStorage` with `MnemonicSignerConfig`*/
    fun createMnemonicSigner(
        config: MnemonicSignerConfig,
        password: String,
        salt: String
    ): SignerStoreItem
    /** */
//    @Throws(Throwable::class)
//    fun addAccount(
//        item: SignerStoreItem,
//        password: String,
//        salt: String,
//        derivationPath: String? = null
//    ): SignerStoreItem
    /** Add `KeyStoreItem` using password and SecreteStorage.
     *
     * NOTE: It first attempts to delete any `KeyStoreItem` or `SecreteStorage`
     * that might be present with same `KeyStoreItem.uuid`
     */
    fun add(item: SignerStoreItem, password: String, secretStorage: SecretStorage)
    /** Removes `KeyStoreItem` and its corresponding `SecretStorage` */
    fun remove(item: SignerStoreItem)
    /** Lists all the items in `KeyStore` */
    fun items(): List<SignerStoreItem>
    /** Retrieves `SecretStorage` for `KeyStoreItem` using password */
    fun secretStorage(item: SignerStoreItem, password: String): SecretStorage?
    /** Does device support biometrics authentication */
    fun biometricsSupported(): Boolean
    /** Authenticate with biometrics */
    fun biometricsAuthenticate(title: String, handler: (Boolean, Error?) -> Unit)
    /** Retrieves password from keychain if one is present */
    fun password(item: SignerStoreItem): String?
}

class DefaultSignerStoreService(
    private val store: KeyValueStore,
    private val keyChainService: KeyChainService
) : SignerStoreService {

    override var selected: SignerStoreItem?
    get() = store.get<SignerStoreItem>(selectedKey)
    set(value) = store.set(selectedKey, value)

    override fun createMnemonicSigner(
        config: MnemonicSignerConfig,
        password: String,
        salt: String
    ): SignerStoreItem {
        val bip39 = Bip39(config.mnemonic, salt, config.wordList)
        val bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        val derivationPath = Network.ethereum().defaultDerivationPath()
        val extKey = bip44.deriveChildKey(derivationPath)
        val signerStoreItem = SignerStoreItem(
            uuid = UUIDService().uuidString(),
            name = config.name,
            sortOrder = (items().lastOrNull()?.sortOrder ?: 0u) + 100u,
            type = SignerStoreItem.Type.MNEMONIC,
            passUnlockWithBio = config.passUnlockWithBio,
            iCloudSecretStorage = config.iCloudSecretStorage,
            saltMnemonic = config.saltMnemonic,
            passwordType = config.passwordType,
            derivationPath = derivationPath,
            addresses = addresses(bip44)
        )
        val secretStorage = SecretStorage.encryptDefault(
            id = signerStoreItem.uuid,
            data = extKey.key,
            password = password,
            address = Network.ethereum().address(extKey.xpub()).toHexString(true),
            mnemonic = bip39.mnemonic.joinToString(" "),
            mnemonicLocale = bip39.worldList.localeString(),
            mnemonicPath = derivationPath
        )
        add(signerStoreItem, password, secretStorage)
        return signerStoreItem
    }

    // TODO("Refactor this away. Ideally we don't want network in signers")
    @Throws(Throwable::class)
    private fun addresses(bip44: Bip44): Map<String, String> {
        val addresses: MutableMap<String, String> = mutableMapOf()
        NetworksService.supportedNetworks().forEach {
            val path = it.defaultDerivationPath()
            val xPub = bip44.deriveChildKey(path).xpub()
            addresses[path] = it.address(xPub).toHexString(true)
        }
        return addresses
    }

    override fun add(
        item: SignerStoreItem,
        password: String,
        secretStorage: SecretStorage
    ) {
        this.remove(item)
        when {
            item.passwordType == SignerStoreItem.PasswordType.BIO ||
            item.passUnlockWithBio -> keyChainService.set(
                item.uuid,
                ProtoBuf.encodeToByteArray(password),
                ServiceType.PASSWORD,
                item.passwordType == SignerStoreItem.PasswordType.BIO
            )
        }
        keyChainService.set(
            item.uuid,
            ProtoBuf.encodeToByteArray(secretStorage),
            ServiceType.SECRET_STORAGE,
            item.iCloudSecretStorage
        )
        store[item.uuid] = item
    }

    override fun remove(item: SignerStoreItem) {
        keyChainService.remove(item.uuid, ServiceType.PASSWORD)
        keyChainService.remove(item.uuid, ServiceType.SECRET_STORAGE)
        store[item.uuid] = null
    }

    override fun items(): List<SignerStoreItem> {
        return store.allKeys()
            .filter { it != selectedKey }
            .mapNotNull { store.get<SignerStoreItem>(it) }
            .sortedBy { it.sortOrder }
    }

    override fun secretStorage(item: SignerStoreItem, password: String): SecretStorage? {
        return try {
            ProtoBuf.decodeFromByteArray<SecretStorage>(
                keyChainService.get(item.uuid, ServiceType.SECRET_STORAGE)
            )
        } catch (exception: Exception) { null }
    }

    override fun biometricsSupported(): Boolean = keyChainService.biometricsSupported()

    override fun biometricsAuthenticate(title: String, handler: (Boolean, Error?) -> Unit) {
        keyChainService.biometricsAuthenticate(title, handler)
    }

    override fun password(item: SignerStoreItem): String? {
        return try {
            ProtoBuf.decodeFromByteArray<String>(
                keyChainService.get(item.uuid, ServiceType.PASSWORD)
            )
        } catch (error: Throwable) { null }
    }
}