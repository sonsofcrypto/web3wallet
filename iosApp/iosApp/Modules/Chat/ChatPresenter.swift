// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ChatPresenterEvent {

    case send(message: String)
    case receive(message: String)
}

protocol ChatPresenter {

    func present()
    func handle(_ event: ChatPresenterEvent)
}

final class DefaultChatPresenter {

    private weak var view: ChatView?
    private let interactor: ChatInteractor
    private let wireframe: ChatWireframe
    
    private var step = 1
    private var items = [ChatViewModel.Item]()

    init(
        view: ChatView,
        interactor: ChatInteractor,
        wireframe: ChatWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultChatPresenter: ChatPresenter {

    func present() {
        
        prepareFirstItem()
        updateView()
    }

    func handle(_ event: ChatPresenterEvent) {

        switch event {
            
        case let .send(message):
            markMessagesAsNotNew()
            items.append(
                .init(
                    owner: .me,
                    message: message,
                    isNewMessage: true
                )
            )
            updateView()
            scheduleReceiveNextMessage()
            
        case let .receive(message):
            markMessagesAsNotNew()
            items.append(
                .init(
                    owner: .other,
                    message: message,
                    isNewMessage: true
                )
            )
            updateView()
        }
    }
}

private extension DefaultChatPresenter {
    
    func markMessagesAsNotNew() {
        items = items.compactMap {
            .init(
                owner: $0.owner,
                message: $0.message,
                isNewMessage: false
            )
        }
    }
    
    func updateView() {
        
        let viewModel = makeViewModel()
        view?.update(with: viewModel)
    }
    
    func makeViewModel() -> ChatViewModel {
        
        .loaded(items: items, selectedIdx: items.count - 1)
    }

    func prepareFirstItem() {
        
        items.append(
            .init(
                owner: .other,
                message: Localized("chat.friend.message1"),
                isNewMessage: true
            )
        )
    }
    
    func scheduleReceiveNextMessage() {
        
        switch items.last?.message {
            
        case Localized("chat.me.message1"):
            let message1 = Localized("chat.friend.message2")
            receiveMessage(message1, after: 1.5)
            let message2 = Localized("chat.friend.message3")
            receiveMessage(message2, after: 3.0)
            
        case Localized("chat.me.message3"):
            
            let message1 = Localized("chat.friend.message4")
            receiveMessage(message1, after: 1.5)
            let message2 = Localized("chat.friend.message5")
            receiveMessage(message2, after: 3.0)
            let message3 = Localized("chat.friend.message6")
            receiveMessage(message3, after: 4.0)
            let message4 = Localized("chat.friend.message7")
            receiveMessage(message4, after: 6.0)

        default:
            break
        }
    }
    
    func receiveMessage(_ string: String, after delay: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            
            guard let self = self else { return }
            self.handle(.receive(message: string))
        }
    }
}
