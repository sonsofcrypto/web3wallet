package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.cult.CultService
import com.sonsofcrypto.web3walletcore.services.cult.DefaultCultService
import smartadapter.internal.extension.name

class CultServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CultService::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultCultService(
                it.resolve("${KeyValueStore::class.name}.CultService"),
            )
        }
    }
}