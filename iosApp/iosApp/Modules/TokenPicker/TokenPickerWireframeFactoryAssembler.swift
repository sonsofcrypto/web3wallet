// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenPickerWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> TokenPickerWireframeFactory in
            
            DefaultTokenPickerWireframeFactory(
                tokenAddWireframeFactory: resolver.resolve(),
                web3Service: resolver.resolve()
            )
        }
    }
}
