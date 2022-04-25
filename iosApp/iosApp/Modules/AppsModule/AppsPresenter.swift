// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AppsPresenterEvent {

}

protocol AppsPresenter {

    func present()
    func handle(_ event: AppsPresenterEvent)
}

// MARK: - DefaultAppsPresenter

class DefaultAppsPresenter {

    private let interactor: AppsInteractor
    private let wireframe: AppsWireframe

    // private var items: [Item]

    private weak var view: AppsView?

    init(
        view: AppsView,
        interactor: AppsInteractor,
        wireframe: AppsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: AppsPresenter

extension DefaultAppsPresenter: AppsPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: AppsPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultAppsPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultAppsPresenter {

//    func viewModel(from items: [Item], active: Item?) -> AppsViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
