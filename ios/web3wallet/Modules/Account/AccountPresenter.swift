// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AccountPresenterEvent {

}

protocol AccountPresenter {

    func present()
    func handle(_ event: AccountPresenterEvent)
}

// MARK: - DefaultAccountPresenter

class DefaultAccountPresenter {

    private let interactor: AccountInteractor
    private let wireframe: AccountWireframe

    // private var items: [Item]

    private weak var view: AccountView?

    init(
        view: AccountView,
        interactor: AccountInteractor,
        wireframe: AccountWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: AccountPresenter

extension DefaultAccountPresenter: AccountPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: AccountPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultAccountPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultAccountPresenter {

//    func viewModel(from items: [Item], active: Item?) -> AccountViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
