// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class CurrencyMetadataServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> CurrencyMetadataService in
            DefaultCurrencyMetadataService(
                bundledAssetProvider: BundledAssetProvider(),
                coinGeckoService: DefaultCoinGeckoService(),
                currenciesInfoStore: resolver.resolve()
            )
        }
    }
}