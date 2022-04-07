//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class DashboardWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> DashboardWireframeFactory in
            
            DefaultDashboardWireframeFactory(
                service: resolver.resolve(),
                accountWireframeFactory: resolver.resolve()
            )
        }
    }
}
