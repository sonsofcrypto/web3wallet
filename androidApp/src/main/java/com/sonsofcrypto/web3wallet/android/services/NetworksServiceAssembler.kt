package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.networks.DefaultNetworksService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.node.NodeService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class NetworksServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(NetworksService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultNetworksService(
                it.resolve("${KeyValueStore::class.name}.NetworksService"),
                it.resolve(KeyStoreService::class.name),
                it.resolve(NodeService::class.name),
            )
        }
    }
}