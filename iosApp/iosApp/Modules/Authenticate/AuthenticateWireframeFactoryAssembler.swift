// Created by web3d4v on 19 /07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class AuthenticateWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> AuthenticateWireframeFactory in
            
            DefaultAuthenticateWireframeFactory(
                keyStoreService: resolver.resolve()
            )
        }
    }
}
