// Created by web3d4v on 26/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class MnemonicImportWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> MnemonicImportWireframeFactory in
            
            DefaultMnemonicImportWireframeFactory(
                keyStoreService: resolver.resolve()
            )
        }
    }
}
