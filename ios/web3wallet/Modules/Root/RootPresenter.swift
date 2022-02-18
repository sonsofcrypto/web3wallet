// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum RootPresenterEvent {

}

protocol RootPresenter {

    func present()
    func handle(_ event: RootPresenterEvent)
}

// MARK: - DefaultRootPresenter

class DefaultRootPresenter {

    private let wireframe: RootWireframe

    // private var items: [Item]

    private weak var view: RootView?

    init(
        view: RootView,
        wireframe: RootWireframe
    ) {
        self.view = view
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: RootPresenter

extension DefaultRootPresenter: RootPresenter {

    func present() {
        // TODO: Interactor
    }

    func handle(_ event: RootPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultRootPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultRootPresenter {

//    func viewModel(from items: [Item], active: Item?) -> RootViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
