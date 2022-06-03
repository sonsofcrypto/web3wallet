// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ChatWireframeFactory {

    func makeWireframe(
        presentingIn: NavigationController,
        context: ChatWireframeContext
    ) -> ChatWireframe
}

final class DefaultChatWireframeFactory {

    private let chatService: ChatService

    init(
        chatService: ChatService
    ) {
        self.chatService = chatService
    }
}

extension DefaultChatWireframeFactory: ChatWireframeFactory {

    func makeWireframe(
        presentingIn: NavigationController,
        context: ChatWireframeContext
    ) -> ChatWireframe {
        
        DefaultChatWireframe(
            presentingIn: presentingIn,
            context: context,
            chatService: chatService
        )
    }
}
