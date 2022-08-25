// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class NFTsDashboardWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> NFTsDashboardWireframeFactory in
            
            DefaultNFTsDashboardWireframeFactory(
                nftsCollectionWireframeFactory: resolver.resolve(),
                nftDetailWireframeFactory: resolver.resolve(),
                nftsService: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
