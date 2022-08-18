// Created by web3d4v on 14/07/2022..
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class MnemonicUpdateWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> MnemonicUpdateWireframeFactory in
            
            DefaultMnemonicUpdateWireframeFactory(
                keyStoreService: resolver.resolve(),
                authenticateWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve()
            )
        }
    }
}
