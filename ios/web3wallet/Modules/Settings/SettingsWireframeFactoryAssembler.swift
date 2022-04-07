//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class SettingsWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> SettingsWireframeFactory in
            
            DefaultSettingsWireframeFactory(
                service: resolver.resolve()
            )
        }
    }
}
