package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.coinGecko.CoinGeckoService
import com.sonsofcrypto.web3lib.services.coinGecko.DefaultCoinGeckoService
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.currencyStore.DefaultCurrencyStoreService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class CurrencyStoreServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(CurrencyStoreService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultCurrencyStoreService(
                it.resolve("${CoinGeckoService::class.name}"),
                it.resolve("${KeyValueStore::class.name}.Market"),
                it.resolve("${KeyValueStore::class.name}.Candle"),
                it.resolve("${KeyValueStore::class.name}.Metadata"),
                it.resolve("${KeyValueStore::class.name}.UserCurrency"),
            )
            // TODO: Review loading Cache...should not be done by the assembler
//            service.loadCaches(
//                NetworksService.Companion.supportedNetworks(),
//            )
            // return service
        }
    }
}