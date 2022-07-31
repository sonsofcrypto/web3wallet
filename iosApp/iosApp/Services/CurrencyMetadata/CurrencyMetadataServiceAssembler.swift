// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class CurrencyMetadataServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { _ -> CurrencyMetadataService in
            DefaultCurrencyMetadataService(
                bundledImageProvider: BundledImageProvider(),
                coinGeckoService: DefaultCoinGeckoService()
            )
        }
    }
}