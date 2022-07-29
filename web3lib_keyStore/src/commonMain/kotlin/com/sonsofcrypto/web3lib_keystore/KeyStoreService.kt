package com.sonsofcrypto.web3lib_keystore

import com.sonsofcrypto.keyvaluestore.KeyValueStore
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

private val selectedKey = "selected_uuid"

/**
 * Handles management of `KeyStoreItem`s and `SecretStorage` items.
 */
interface KeyStoreService {
    /** Latest selected `KeyStoreItem` (persists between launches) */
    var selected: KeyStoreItem?
    /** Add `KeyStoreItem` using password and SecreteStorage.
     *
     * NOTE: It first attempts to delete any `KeyStoreItem` or `SecreteStorage`
     * that might be present with same `KeyStoreItem.uuid`
     */
    fun add(item: KeyStoreItem, password: String, secretStorage: SecretStorage)
    /** Removes `KeyStoreItem` and its corresponding `SecretStorage` */
    fun remove(item: KeyStoreItem)
    /** Lists all the items in `KeyStore` */
    fun items(): List<KeyStoreItem>
    /** Retrieves `SecretStorage` for `KeyStoreItem` using password */
    fun secretStorage(item: KeyStoreItem, password: String): SecretStorage?
    /** Does device support biometrics authentication */
    fun biometricsSupported(): Boolean
    /** Authenticate with biometrics */
    fun biometricsAuthenticate(title: String, handler: (Boolean, Error?) -> Unit)
    /** Retrieves password from keychain if one is present */
    fun password(item: KeyStoreItem): String?
}

class DefaultKeyStoreService(
    private val store: KeyValueStore,
    private val keyChainService: KeyChainService
) : KeyStoreService {

    override var selected: KeyStoreItem?
    get() = store.get<KeyStoreItem>(selectedKey)
    set(value) = store.set(selectedKey, value)

    override fun add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) {
        this.remove(item)
        when {
            item.passwordType == KeyStoreItem.PasswordType.BIO ||
            item.passUnlockWithBio -> keyChainService.set(
                item.uuid,
                ProtoBuf.encodeToByteArray(password),
                ServiceType.PASSWORD,
                item.passwordType == KeyStoreItem.PasswordType.BIO
            )
        }
        keyChainService.set(
            item.uuid,
            ProtoBuf.encodeToByteArray(secretStorage),
            ServiceType.SECRET_STORAGE,
            item.iCloudSecretStorage
        )
        store.set(item.uuid, item)
    }

    override fun remove(item: KeyStoreItem) {
        keyChainService.remove(item.uuid, ServiceType.PASSWORD)
        keyChainService.remove(item.uuid, ServiceType.SECRET_STORAGE)
        store.set(item.uuid, null)
    }

    override fun items(): List<KeyStoreItem> {
        return store.allKeys()
            .filter { it != selectedKey }
            .mapNotNull { store.get<KeyStoreItem>(it) }
            .sortedBy { it.sortOrder }
    }

    override fun secretStorage(item: KeyStoreItem, password: String): SecretStorage? {
        try {
            return ProtoBuf.decodeFromByteArray<SecretStorage>(
                keyChainService.get(item.uuid, ServiceType.SECRET_STORAGE)
            )
        } catch (exception: Exception) {
            return null
        }
    }

    override fun biometricsSupported(): Boolean = keyChainService.biometricsSupported()

    override fun biometricsAuthenticate(title: String, handler: (Boolean, Error?) -> Unit) {
        keyChainService.biometricsAuthenticate(title, handler)
    }

    override fun password(item: KeyStoreItem): String? {
        try {
            return ProtoBuf.decodeFromByteArray<String>(
                keyChainService.get(item.uuid, ServiceType.PASSWORD)
            )
        } catch (error: Throwable) {
            return null
        }
    }
}