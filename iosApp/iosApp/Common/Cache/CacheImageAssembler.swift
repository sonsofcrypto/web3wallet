// Created by web3d4v on 28/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class CacheImageAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> CacheImage in
            
            MemoryCacheImage()
        }
    }
}
