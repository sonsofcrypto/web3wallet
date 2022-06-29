// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class ChatWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> ChatWireframeFactory in
            
            DefaultChatWireframeFactory(
                chatService: resolver.resolve()
            )
        }
    }
}
