//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class NetworksWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> NetworksWireframeFactory in
            
            DefaultNetworksWireframeFactory(
                networksService: resolver.resolve()
            )
        }
    }
}
