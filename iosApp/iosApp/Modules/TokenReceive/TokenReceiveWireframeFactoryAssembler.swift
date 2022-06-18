// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenReceiveWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> TokenReceiveWireframeFactory in
            
            DefaultTokenReceiveWireframeFactory(
                web3Service: resolver.resolve()
            )
        }
    }
}
