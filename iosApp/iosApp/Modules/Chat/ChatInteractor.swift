// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol ChatInteractor: AnyObject {}

final class DefaultChatInteractor {
    private var chatService: ChatService

    init(chatService: ChatService) {
        self.chatService = chatService
    }
}

extension DefaultChatInteractor: ChatInteractor {}
