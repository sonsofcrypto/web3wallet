package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.etherScan.DefaultEtherScanService
import com.sonsofcrypto.web3walletcore.services.etherScan.EtherScanService
import smartadapter.internal.extension.name

class EtherScanServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(EtherScanService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultEtherScanService(
                it.resolve("${KeyValueStore::class.name}.EtherScanService"),
            )
        }
    }
}