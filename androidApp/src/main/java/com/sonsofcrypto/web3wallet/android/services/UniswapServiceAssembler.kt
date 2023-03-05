package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.services.uniswap.DefaultUniswapService
import com.sonsofcrypto.web3lib.services.uniswap.UniswapService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class UniswapServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(UniswapService::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultUniswapService()
        }
    }
}

