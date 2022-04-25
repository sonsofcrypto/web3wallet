// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class AccountWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> AccountWireframeFactory in
            
            DefaultAccountWireframeFactory(
                accountService: resolver.resolve()
            )
        }
    }
}
