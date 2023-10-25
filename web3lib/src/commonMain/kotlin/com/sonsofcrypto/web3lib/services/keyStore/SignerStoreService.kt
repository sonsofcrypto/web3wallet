package com.sonsofcrypto.web3lib.services.keyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.address.defaultDerivationPath
import com.sonsofcrypto.web3lib.services.uuid.UUIDService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.bip39.localeString
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
    val derivationPath: String = AddressService.defaultDerivationPath(),
    val sortOrder: UInt? = null,
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
    /** Creates SignerStoreItem item at `derivationPath` or last path component
     * + 1 */
    @Throws(Throwable::class)
    fun addAccount(
        item: SignerStoreItem,
        password: String,
        salt: String,
        derivationPath: String? = null
    ): SignerStoreItem
    /** Add `KeyStoreItem` using password and SecreteStorage.
     *
     * NOTE: It first attempts to delete any `SignerStoreItem` or
     * `SecreteStorage` that might be present with same `SignerStoreItem.uuid`
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
    fun biometricAuthenticate(title: String, handler: (Boolean, Error?) -> Unit)
    /** Retrieves password from keychain if one is present */
    fun password(item: SignerStoreItem): String?
    /** Updates sort order of `SignerStoreItem` */
    fun updateSortOrder(item: SignerStoreItem, idx: UInt)
}

class DefaultSignerStoreService(
    private val store: KeyValueStore,
    private val keyChainService: KeyChainService,
    private val addressService: AddressService,
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
        val extKey = bip44.deriveChildKey(config.derivationPath)
        val address = addressService.address(
            bip44.deriveChildKey(config.derivationPath).xpub()
        )
        val signerStoreItem = SignerStoreItem(
            uuid = UUIDService().uuidString(),
            name = config.name,
            sortOrder = (items().lastOrNull()?.sortOrder ?: 0u) + 100u,
            type = SignerStoreItem.Type.MNEMONIC,
            passUnlockWithBio = config.passUnlockWithBio,
            iCloudSecretStorage = config.iCloudSecretStorage,
            saltMnemonic = config.saltMnemonic,
            passwordType = config.passwordType,
            derivationPath = config.derivationPath,
            addresses = mapOf(config.derivationPath to address)
        )
        val secretStorage = SecretStorage.encryptDefault(
            id = signerStoreItem.uuid,
            data = extKey.key,
            password = password,
            address = address,
            mnemonic = bip39.mnemonic.joinToString(" "),
            mnemonicLocale = bip39.worldList.localeString(),
            mnemonicPath = config.derivationPath
        )
        this.add(signerStoreItem, password, secretStorage)
        return signerStoreItem
    }

    @Throws(Throwable::class)
    override fun addAccount(
        item: SignerStoreItem,
        password: String,
        salt: String,
        derivationPath: String?
    ): SignerStoreItem {
        if (item.type != SignerStoreItem.Type.MNEMONIC)
            throw Err.AddAccountForNonMnemonic
        val path = derivationPath ?: this.nextDerivationPath(item)
        val decrypted = this.secretStorage(item, password)?.decrypt(password)
            ?: throw Err.AddAccountDecryptFailed
        return createMnemonicSigner(
            MnemonicSignerConfig(
                mnemonic = decrypted.mnemonic!!.split(" "),
                name = item.name + ", acc: ${lastDerivationPathComponent(path)}",
                passUnlockWithBio = item.passUnlockWithBio ,
                iCloudSecretStorage = item.iCloudSecretStorage,
                saltMnemonic = item.saltMnemonic,
                passwordType = item.passwordType,
                wordList = WordList.fromLocaleString(decrypted.mnemonicLocale),
                derivationPath = path,
                sortOrder =  item.sortOrder + 1u,
            ),
            password,
            salt,
        )
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
        fixSortOrderIfNeeded(item)
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

    override fun biometricsSupported(): Boolean
        = keyChainService.biometricsSupported()

    override fun biometricAuthenticate(title: String, handler: (Boolean, Error?) -> Unit) {
        keyChainService.biometricsAuthenticate(title, handler)
    }

    override fun password(item: SignerStoreItem): String? {
        return try {
            ProtoBuf.decodeFromByteArray<String>(
                keyChainService.get(item.uuid, ServiceType.PASSWORD)
            )
        } catch (error: Throwable) { null }
    }

    override fun updateSortOrder(item: SignerStoreItem, idx: UInt) {
        store[item.uuid] = item.copy(sortOrder = idx)
    }

    @OptIn(kotlin.ExperimentalStdlibApi::class)
    private fun fixSortOrderIfNeeded(insertedItem: SignerStoreItem) {
        val items = this.items()
        if (items.count() < 2)
            return
        var prevSortOrder = items[0].sortOrder
        for (i in 1..<items.count()) {
            var item = items[i]
            if (prevSortOrder == item.sortOrder) {
                prevSortOrder += 1u
                if (item.uuid == insertedItem.uuid)
                    item = items[i - 1]
                this.updateSortOrder(item, prevSortOrder)
            } else {
                prevSortOrder = item.sortOrder
            }
        }
    }

    @Throws(Throwable::class)
    private fun nextDerivationPath(item: SignerStoreItem): String {
        if (item.type != SignerStoreItem.Type.MNEMONIC)
            throw Err.AddAccountForNonMnemonic
        if (item.parentId != null) {
            val lastItem = this.items()
                .filter { it.parentId == item.parentId }
                .sortedBy { lastDerivationPathComponent(it.derivationPath) }
                .lastOrNull()
            if (lastItem?.derivationPath != null)
                return incrementedDerivationPath(lastItem.derivationPath)
        }
        return incrementedDerivationPath(item.derivationPath)
    }

    private fun lastDerivationPathComponent(path: String): Int
            = path.split("/").last().toInt()

    private fun incrementedDerivationPath(path: String): String {
        val splitPath = path.split("/")
        val nextIdx = splitPath.last().toInt() + 1
        return (splitPath.dropLast(1) + nextIdx.toString()).joinToString("/")
    }

    /** Exceptions */
    sealed class Err(message: String? = null) : Exception(message) {
        /** Attempting to add account to non-mnemonic signer */
        object AddAccountForNonMnemonic :
            Err("Attempting to add account to non-mnemonic signer")
        /** Failed while attempting to decrypt existing mnemonic */
        object AddAccountDecryptFailed :
            Err("Failed to decrypt parent secrete storage")
    }
}