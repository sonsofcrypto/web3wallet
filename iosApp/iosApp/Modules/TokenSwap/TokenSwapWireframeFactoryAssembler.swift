// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSwapWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> TokenSwapWireframeFactory in
            
            DefaultTokenSwapWireframeFactory(
                tokenPickerWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                web3Service: resolver.resolve()
            )
        }
    }
}
