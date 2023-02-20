package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.degen.DefaultDegenService
import com.sonsofcrypto.web3walletcore.services.degen.DegenService
import smartadapter.internal.extension.name

class DegenServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(DegenService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultDegenService(
                it.resolve(WalletService::class.name)
            )
        }
    }
}