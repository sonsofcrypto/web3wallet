// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class NFTsCollectionWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> NFTsCollectionWireframeFactory in
            
            DefaultNFTsCollectionWireframeFactory(
                nftDetailWireframeFactory: resolver.resolve(),
                nftsService: resolver.resolve()
            )
        }
    }
}
