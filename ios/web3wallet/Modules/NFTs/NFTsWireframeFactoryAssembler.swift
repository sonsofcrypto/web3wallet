//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class NFTsWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> NFTsWireframeFactory in
            
            DefaultNFTsWireframeFactory(
                service: resolver.resolve()
            )
        }
    }
}
