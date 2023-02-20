package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.services.keyStore.KeyChainService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.services.keychain.DefaultKeyChainService
import smartadapter.internal.extension.name

class KeyChainServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(KeyChainService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultKeyChainService()
        }
    }
}