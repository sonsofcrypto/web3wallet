package com.sonsofcrypto.web3wallet.android.services

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import smartadapter.internal.extension.name

class KeyValueStoreAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        val name = KeyValueStore::class.name
        to.register("$name.ActionsService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.ActionsService")
        }
        to.register("$name.CultService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.CultService")
        }
        to.register("$name.Market", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.Market")
        }
        to.register("$name.Candle", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.Candle")
        }
        to.register("$name.Metadata", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.Metadata")
        }
        to.register("$name.UserCurrency", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.UserCurrency")
        }
        to.register("$name.ImprovementProposalsService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.ImprovementProposalsService")
        }
        to.register("$name.KeyStoreService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.KeyStoreService")
        }
        to.register("$name.NetworksService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.NetworksService")
        }
        to.register("$name.NFTsService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.NFTsService")
        }
        to.register("$name.WalletService.Currencies", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.WalletService.Currencies")
        }
        to.register("$name.WalletService.NetworksState", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.WalletService.NetworksState")
        }
        to.register("$name.WalletService.TransferLogsCache", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.WalletService.TransferLogsCache")
        }
        to.register("$name.SettingsService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.SettingsService")
        }
        to.register("$name.EtherScanService", AssemblerRegistryScope.SINGLETON) {
            KeyValueStore("$name.EtherScanService")
        }
    }
}