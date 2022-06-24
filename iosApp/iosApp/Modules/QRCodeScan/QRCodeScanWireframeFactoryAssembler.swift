// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class QRCodeScanWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> QRCodeScanWireframeFactory in
            
            DefaultQRCodeScanWireframeFactory(
                web3Service: resolver.resolve()
            )
        }
    }
}
