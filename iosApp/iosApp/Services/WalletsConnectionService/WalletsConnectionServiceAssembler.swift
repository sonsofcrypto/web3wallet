// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class WalletsConnectionServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> WalletsConnectionService in
            let keyStoreService: KeyStoreService = resolver.resolve()
            let web3service = DefaultWalletsConnectionService(
                store: KeyValueStore(name: "\(DefaultWalletsConnectionService.self)")
            )
            if let keyStoreItem = keyStoreService.selected {
                web3service.wallet = Wallet(
                    keyStoreItem: keyStoreItem,
                    keyStoreService: keyStoreService,
                    provider: nil
                )
            }
            return web3service
        }
    }
}