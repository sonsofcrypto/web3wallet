package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.services.settings.DefaultSettingsServiceActionTrigger
import com.sonsofcrypto.web3walletcore.services.settings.SettingsServiceActionTrigger
import smartadapter.internal.extension.name

class SettingsServiceActionTriggerAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(SettingsServiceActionTrigger::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultSettingsServiceActionTrigger()
        }
    }
}

