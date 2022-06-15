// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenDetailsWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> TokenDetailsWireframeFactory in
            
            DefaultTokenDetailsWireframeFactory(
                web3Service: resolver.resolve()
            )
        }
    }
}
