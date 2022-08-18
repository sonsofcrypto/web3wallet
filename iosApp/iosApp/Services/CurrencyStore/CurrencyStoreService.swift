// Created by web3d3v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class CurrencyStoreServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> CurrencyStoreService in
            let service = DefaultCurrencyStoreService(
                coinGeckoService: DefaultCoinGeckoService(),
                marketStore: KeyValueStore(name: "CurrencyStoreService.Market"),
                candleStore: KeyValueStore(name: "CurrencyStoreService.Candle"),
                userCurrencyStore: KeyValueStore(
                    name: "CurrencyStoreService.UserCurrency"
                )
            )
            service.loadCaches(NetworksServiceCompanion().supportedNetworks())
            return service
        }
    }
}
