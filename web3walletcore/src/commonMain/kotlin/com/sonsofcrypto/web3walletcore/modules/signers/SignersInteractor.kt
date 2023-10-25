package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService

interface SignersInteractor {
    var selected: SignerStoreItem?
    val items: List<SignerStoreItem>
    fun add(item: SignerStoreItem, password: String, secretStorage: SecretStorage)
}

class DefaultSignersInteractor(
    private var signerStoreService: SignerStoreService,
    private var networksService: NetworksService,
): SignersInteractor {

    override var selected: SignerStoreItem?
        get() = signerStoreService.selected
        set(value) {
            signerStoreService.selected = value
            if (value != null) {
                networksService.signerStoreItem = value
            }
        }

    override val items: List<SignerStoreItem> get() = signerStoreService.items()

    override fun add(item: SignerStoreItem, password: String, secretStorage: SecretStorage) {
        signerStoreService.add(item, password, secretStorage)
    }
}
