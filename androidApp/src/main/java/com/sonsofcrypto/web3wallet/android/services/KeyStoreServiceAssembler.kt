package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.keyStore.DefaultKeyStoreService
import com.sonsofcrypto.web3lib.services.keyStore.KeyChainService
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class KeyStoreServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(KeyStoreService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultKeyStoreService(
                it.resolve("${KeyValueStore::class.name}.KeyStoreService"),
                it.resolve(KeyChainService::class.name),
            )
        }
    }
}