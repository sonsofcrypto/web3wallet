package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import com.sonsofcrypto.web3walletcore.services.nfts.OpenSeaNFTsService
import smartadapter.internal.extension.name

class NFTsServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(NFTsService::class.name, AssemblerRegistryScope.SINGLETON) {
            OpenSeaNFTsService(
                it.resolve(NetworksService::class.name),
                it.resolve("${KeyValueStore::class.name}.NFTsService"),
            )
        }
    }
}