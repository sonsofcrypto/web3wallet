package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.settings.DefaultSettingsService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService
import smartadapter.internal.extension.name

class SettingsServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(SettingsService::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultSettingsService(
                it.resolve("${KeyValueStore::class.name}.SettingsService"),
            )
        }
    }
}

