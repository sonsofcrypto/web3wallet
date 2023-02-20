package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.services.coinGecko.CoinGeckoService
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class CoinGeckoServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CoinGeckoService::class.name, AssemblerRegistryScope.SINGLETON) {

            DefaultCoinGeckoService()
        }
    }
}