// Created by web3d4v on 14/07/2022..
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class MnemonicNewWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> MnemonicNewWireframeFactory in
            
            DefaultMnemonicNewWireframeFactory(
                keyStoreService: resolver.resolve(),
                settingsService: resolver.resolve()
            )
        }
    }
}
