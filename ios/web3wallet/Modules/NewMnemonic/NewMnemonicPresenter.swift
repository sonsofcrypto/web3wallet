// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NewMnemonicPresenterEvent {

}

protocol NewMnemonicPresenter {

    func present()
    func handle(_ event: NewMnemonicPresenterEvent)
}

// MARK: - DefaultNewMnemonicPresenter

class DefaultNewMnemonicPresenter {

    private let interactor: NewMnemonicInteractor
    private let wireframe: NewMnemonicWireframe

    // private var items: [Item]

    private weak var view: NewMnemonicView?

    init(
        view: NewMnemonicView,
        interactor: NewMnemonicInteractor,
        wireframe: NewMnemonicWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: NewMnemonicPresenter

extension DefaultNewMnemonicPresenter: NewMnemonicPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: NewMnemonicPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultNewMnemonicPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultNewMnemonicPresenter {

//    func viewModel(from items: [Item], active: Item?) -> TemplateViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
