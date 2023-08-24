// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class NetworksServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> NetworksService in
            DefaultNetworksService(
                store: KeyValueStore(name: "\(DefaultNetworksService.self)"),
                keyStoreService: resolver.resolve(),
                pollService: resolver.resolve(),
                nodeService: resolver.resolve()
            )
        }
    }
}
