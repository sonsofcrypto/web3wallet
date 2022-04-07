//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class DegenWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> DegenWireframeFactory in
            
            DefaultDegenWireframeFactory(
                service: resolver.resolve(),
                ammsWireframeFactory: resolver.resolve()
            )
        }
    }
}
