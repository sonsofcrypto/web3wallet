package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.mnemonic.DefaultMnemonicService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import smartadapter.internal.extension.name

class MnemonicServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(MnemonicService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultMnemonicService()
        }
    }
}