//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class RootWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> RootWireframeFactory in
            
            DefaultRootWireframeFactory(
                wallets: resolver.resolve(),
                networks: resolver.resolve(),
                dashboard: resolver.resolve(),
                degen: resolver.resolve(),
                nfts: resolver.resolve(),
                apps: resolver.resolve(),
                settings: resolver.resolve()
            )
        }
    }
}
