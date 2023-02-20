package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class WalletServiceAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(WalletService::class.name, AssemblerRegistryScope.SINGLETON) {
            DefaultWalletService(
                it.resolve(NetworksService::class.name),
                it.resolve(CurrencyStoreService::class.name),
                it.resolve("${KeyValueStore::class.name}.WalletService.Currencies"),
                it.resolve("${KeyValueStore::class.name}.WalletService.NetworksState"),
                it.resolve("${KeyValueStore::class.name}.WalletService.TransferLogsCache"),
            )
        }
    }
}