// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> TokenSendWireframeFactory in
            
            DefaultTokenSendWireframeFactory(
                qrCodeScanWireframeFactory: resolver.resolve(),
                tokenPickerWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                web3Service: resolver.resolve()
            )
        }
    }
}
