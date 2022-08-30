// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class NFTSendWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> NFTSendWireframeFactory in
            
            DefaultNFTSendWireframeFactory(
                qrCodeScanWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                web3Service: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
