// Created by web3d3v on 18/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class KeyStoreWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> KeyStoreWireframeFactory in
            DefaultKeyStoreWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve(),
                networksService: resolver.resolve(),
                newMnemonic: resolver.resolve(),
                updateMnemonic: resolver.resolve(),
                importMnemonic: resolver.resolve(),
                alertWireframeFactory: resolver.resolve()
            )
        }
    }
}
