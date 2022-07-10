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
}

class DefaultKeyStoreService(
    private val store: KeyValueStore,
    private val keyChainService: KeyChainService
) : KeyStoreService {

    override var selected: KeyStoreItem?
    get() = store.get<String>(selectedKey)?.let { store.get<KeyStoreItem>(it) }
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
        val data = keyChainService.get(item.uuid, ServiceType.SECRET_STORAGE)
        if (data != null) {
            return ProtoBuf.decodeFromByteArray<SecretStorage>(data)
        }
        return null
    }
}