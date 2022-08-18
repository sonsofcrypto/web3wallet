// Created by web3d3v on 03/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class WalletServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> WalletService in
            DefaultWalletService(
                networkService: resolver.resolve(),
                currencyStoreService: resolver.resolve(),
                currenciesCache: KeyValueStore(
                    name: "WalletService.currencies"
                ),
                networksStateCache: KeyValueStore(
                    name: "WalletService.networksState"
                )
            )
        }
    }
}