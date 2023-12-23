// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class PollServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> PollService in
            DefaultPollService(blockTimer: false)
        }
    }
}

final class AddressServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> AddressService in
            DefaultAddressService()
        }
    }
}

final class ClipboardServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> ClipboardService in
            ClipboardService()
        }
    }
}

final class SettingsServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> SettingsService in
            DefaultSettingsService(
                store: KeyValueStore(name: "keyValueStore.settingsService")
            )
        }
    }
}

final class WalletServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> WalletService in
            DefaultWalletServiceMulticall(
                networkService: resolver.resolve(),
                currencyStoreService: resolver.resolve(),
                pollService: resolver.resolve(),
                currenciesCache: KeyValueStore(
                    name: "WalletService.currencies"
                ),
                networksStateCache: KeyValueStore(
                    name: "WalletService.networksState"
                ),
                transferLogsCache: KeyValueStore(
                    name: "WalletService.transferLogsCache"
                )
            )
        }
    }
}

final class UniswapServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { _ -> UniswapService in
            DefaultUniswapService()
        }
    }
}

final class MnemonicServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .instance) { resolver -> MnemonicService in
            DefaultMnemonicService()
        }
    }
}

final class PasswordServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> PasswordService in
            DefaultPasswordService()
        }
    }
}


final class NodeServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NodeService in
            DefaultNodeService()
        }
    }
}

final class NFTsServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> NFTsService in
            NFTServiceMoralis(
                networksService: resolver.resolve(),
                store: KeyValueStore(name: "\(NFTsService.self)")
            )
        }
    }
}

final class NetworksServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> NetworksService in
            DefaultNetworksService(
                store: KeyValueStore(name: "\(DefaultNetworksService.self)"),
                signerStoreService: resolver.resolve(),
                pollService: resolver.resolve(),
                nodeService: resolver.resolve()
            )
        }
    }
}

//final class KeyStoreKeyValStoreServiceAssembler: AssemblerComponent {
//    func register(to registry: AssemblerRegistry) {
//        registry.register(scope: .instance) { resolver -> KeyValueStore in
//            KeyValueStore(name: "keyStore")
//        }
//    }
//}

final class SignerStoreServiceAssembler: AssemblerComponent {
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> SignerStoreService in
            DefaultSignerStoreService(
                store: KeyValueStore(name: "keyStore"),
                keyChainService: resolver.resolve(),
                addressService: resolver.resolve()
            )
        }
    }
}

final class ImprovementProposalsServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ImprovementProposalsService in
            DefaultImprovementProposalsService(
                store: KeyValueStore(name: "\(ImprovementProposalsService.self)")
            )
        }
    }
}

final class DegenServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> DegenService in
            DefaultDegenService(walletService: resolver.resolve())
        }
    }
}

final class CurrencyStoreServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> CurrencyStoreService in
            let service = DefaultCurrencyStoreService(
                coinGeckoService: DefaultCoinGeckoService(),
                marketStore: KeyValueStore(name: "CurrencyStoreService.Market"),
                candleStore: KeyValueStore(name: "CurrencyStoreService.Candle"),
                metadataStore: KeyValueStore(name: "CurrencyStoreService.Metadata"),
                userCurrencyStore: KeyValueStore(
                    name: "CurrencyStoreService.UserCurrency"
                )
            )
            service.loadCaches(
                networks: NetworksServiceCompanion().supportedNetworks(),
                completionHandler: { _, _ in () }
            )
            return service
        }
    }
}

final class CultServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> CultService in
            DefaultCultService(
                store: KeyValueStore(name: "\(CultService.self)")
            )
        }
    }
}

final class EtherscanServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> EtherScanService in
            DefaultEtherScanService(
                store: KeyValueStore(name: "\(EtherScanService.self)")
            )
        }
    }
}
