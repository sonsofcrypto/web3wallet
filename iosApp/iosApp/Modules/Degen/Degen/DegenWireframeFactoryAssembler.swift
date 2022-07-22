// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DegenWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> DegenWireframeFactory in
            
            DefaultDegenWireframeFactory(
                cultProposalsWireframeFactory: resolver.resolve(),
                degenService: resolver.resolve()
            )
        }
    }
}
