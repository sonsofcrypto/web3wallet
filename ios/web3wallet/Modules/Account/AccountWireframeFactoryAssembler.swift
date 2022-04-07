//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class AccountWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> AccountWireframeFactory in
            
            DefaultAccountWireframeFactory(
                service: resolver.resolve()
            )
        }
    }
}
