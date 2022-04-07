//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

final class WalletsWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> WalletsWireframeFactory in
            
            DefaultWalletsWireframeFactory(
                walletsService: resolver.resolve()
            )
        }
    }
}
