// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class AccountWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> AccountWireframeFactory in
            
            DefaultAccountWireframeFactory(
                tokenReceiveWireframeFactory: resolver.resolve(),
                tokenSendWireframeFactory: resolver.resolve(),
                tokenSwapWireframeFactory: resolver.resolve(),
                deepLinkHandler: resolver.resolve(),
                priceHistoryService: resolver.resolve()
            )
        }
    }
}
