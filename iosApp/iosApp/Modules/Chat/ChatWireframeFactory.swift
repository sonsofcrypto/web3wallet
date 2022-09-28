// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - ChatWireframeFactory

protocol ChatWireframeFactory {
    func make(_ parent: UIViewController?) -> ChatWireframe
}

// MARK: - DefaultChatWireframeFactory

final class DefaultChatWireframeFactory {
    private let chatService: ChatService

    init(chatService: ChatService) {
        self.chatService = chatService
    }
}

extension DefaultChatWireframeFactory: ChatWireframeFactory {

    func make(_ parent: UIViewController?) -> ChatWireframe {
        DefaultChatWireframe(
            parent,
            chatService: chatService
        )
    }
}

// MARK: - Assembler

final class ChatWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ChatWireframeFactory in
            DefaultChatWireframeFactory(
                chatService: resolver.resolve()
            )
        }
    }
}
