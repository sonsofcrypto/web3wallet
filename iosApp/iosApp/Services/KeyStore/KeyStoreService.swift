// Created by web3d3v on 09/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

// MARK: - Assembler

final class KeyStoreKeyValStoreServiceAssembler: AssemblerComponent {
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> KeyValueStore in
            KeyValueStore(name: "keyStore")
        }
    }
}

final class KeyStoreServiceAssembler: AssemblerComponent {
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> KeyStoreService in
            DefaultKeyStoreService(
                store: resolver.resolve(),
                keyChainService: resolver.resolve()
            )
        }
    }
}
