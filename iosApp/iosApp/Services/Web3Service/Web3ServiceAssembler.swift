// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class Web3ServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> Web3Service in
            let keyStoreService: KeyStoreService = resolver.resolve()
            let web3service = DefaultWeb3Service(
                store: KeyValueStore(name: "\(DefaultWeb3Service.self)")
            )
            if let keyStoreItem = keyStoreService.selected {
                web3service.wallet = Wallet(
                    keyStoreItem: keyStoreItem,
                    keyStoreService: keyStoreService
                )
            }
            return web3service
        }
    }
}