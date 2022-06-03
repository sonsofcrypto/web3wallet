// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ChatPresenterEvent {

}

protocol ChatPresenter {

    func present()
    func handle(_ event: ChatPresenterEvent)
}

final class DefaultChatPresenter {

    private weak var view: ChatView?
    private let interactor: ChatInteractor
    private let wireframe: ChatWireframe

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
        
        view?.update(with: .loading)
    }

    func handle(_ event: ChatPresenterEvent) {

    }
}

private extension DefaultChatPresenter {

}
