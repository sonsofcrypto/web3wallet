package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.services.password.DefaultPasswordService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import smartadapter.internal.extension.name

class PasswordServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(PasswordService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultPasswordService()
        }
    }
}