//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class SwapWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> SwapWireframeFactory in
            
            DefaultSwapWireframeFactory(
                service: resolver.resolve()
            )
        }
    }
}
