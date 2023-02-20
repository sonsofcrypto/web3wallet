package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.improvementProposals.DefaultImprovementProposalsService
import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposalsService
import smartadapter.internal.extension.name

class ImprovementProposalsServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(ImprovementProposalsService::class.name, AssemblerRegistryScope.SINGLETON) {

            DefaultImprovementProposalsService(
                it.resolve("${KeyValueStore::class.name}.ImprovementProposalsService"),
            )
        }
    }
}