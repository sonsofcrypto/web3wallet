// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class NFTsServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> NFTsService in
            
            OpenSeaNFTsService(
                networksService: resolver.resolve(),
                store: KeyValueStore(name: "\(NFTsService.self)")
            )
        }
    }
}
