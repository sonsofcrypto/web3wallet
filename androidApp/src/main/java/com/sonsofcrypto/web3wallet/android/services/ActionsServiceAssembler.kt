package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.actions.DefaultActionsService
import smartadapter.internal.extension.name
import kotlin.reflect.KClass

class ActionsServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(ActionsService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultActionsService(
                it.resolve("${KeyValueStore::class.name}.ActionsService"),
                it.resolve(NetworksService::class.name),
            )
        }
    }
}