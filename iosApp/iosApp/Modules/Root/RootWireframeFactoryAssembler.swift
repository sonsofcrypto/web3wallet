// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class RootWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> RootWireframeFactory in
            
            DefaultRootWireframeFactory(
                keyStoreWireframeFactory: resolver.resolve(),
                networksWireframeFactory: resolver.resolve(),
                dashboardWireframeFactory: resolver.resolve(),
                degenWireframeFactory: resolver.resolve(),
                nftsWireframeFactory: resolver.resolve(),
                appsWireframeFactory: resolver.resolve(),
                settingsWireframeFactory: resolver.resolve(),
                keyStoreService: resolver.resolve()
            )
        }
    }
}
