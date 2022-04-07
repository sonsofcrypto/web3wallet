//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class AppsWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> AppsWireframeFactory in
            
            DefaultAppsWireframeFactory(
                service: resolver.resolve()
            )
        }
    }
}
