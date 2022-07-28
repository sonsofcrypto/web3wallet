// Created by web3d4v on 28/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class KeyStoreWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> KeyStoreWireframeFactory in
            DefaultKeyStoreWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve(),
                newMnemonic: resolver.resolve(),
                updateMnemonic: resolver.resolve(),
                importMnemonic: resolver.resolve()
            )
        }
    }
}
