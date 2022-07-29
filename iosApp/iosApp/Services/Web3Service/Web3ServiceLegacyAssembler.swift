// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class Web3ServiceLegacyAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> Web3ServiceLegacy in
            
//            DefaultWeb3Service(
//                web3ServiceLocalStorage: resolver.resolve()
//            )
            IntegrationWeb3Service(
                web3service: resolver.resolve()
            )
        }
    }
}
