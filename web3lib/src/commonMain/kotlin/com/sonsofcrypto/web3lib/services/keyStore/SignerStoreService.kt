package com.sonsofcrypto.web3lib.services.keyStore

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

private val selectedKey = "selected_uuid"

/**
 * Handles management of `SignerStoreItem`s and `SecretStorage` items.
 */
interface SignerStoreService {
    /** Latest selected `KeyStoreItem` (persists between launches) */
    var selected: SignerStoreItem?
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

    override fun add(item: SignerStoreItem, password: String, secretStorage: SecretStorage) {
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