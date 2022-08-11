// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class NFTDetailWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> NFTDetailWireframeFactory in
            
            DefaultNFTDetailWireframeFactory(
                nftSendWireframeFactory: resolver.resolve(),
                nftsService: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
