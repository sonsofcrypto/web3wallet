package com.sonsofcrypto.web3lib_keystore

import com.sonsofcrypto.keyvaluestore.KeyValueStore
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

interface KeyStoreService {
    fun add(item: KeyStoreItem, password: String, secretStorage: SecretStorage)
    fun remove(item: KeyStoreItem)
    fun items(): List<KeyStoreItem>
    fun secretStorage(item: KeyStoreItem, password: String): SecretStorage?
}

class DefaultKeyStoreService(
    private val store: KeyValueStore,
    private val keyChainService: KeyChainService
) : KeyStoreService {

    override fun add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) {
        this.remove(item)
        when {
            item.passwordType == KeyStoreItem.PasswordType.BIO ||
            item.passUnlockWithBio -> keyChainService.set(
                item.uuid,
                ProtoBuf.encodeToByteArray(password),
                ServiceType.PASSWORD,
                true
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