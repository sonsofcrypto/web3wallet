// Created by web3d4v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class IosEtherscanServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> IosEtherscanService in
            
            DefaultIosEtherscanService(
                networksService: resolver.resolve()
            )
        }
    }
}
