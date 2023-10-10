package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.networks.NetworksService

interface SignersInteractor {
    var selected: KeyStoreItem?
    val items: List<KeyStoreItem>
    fun add(item: KeyStoreItem, password: String, secretStorage: SecretStorage)
}

class DefaultSignersInteractor(
    private var keyStoreService: KeyStoreService,
    private var networksService: NetworksService,
): SignersInteractor {

    override var selected: KeyStoreItem?
        get() = keyStoreService.selected
        set(value) {
            keyStoreService.selected = value
            if (value != null) {
                networksService.keyStoreItem = value
            }
        }

    override val items: List<KeyStoreItem> get() = keyStoreService.items()

    override fun add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) {
        keyStoreService.add(item, password, secretStorage)
    }
}
