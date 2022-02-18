// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AMMsPresenterEvent {

}

protocol AMMsPresenter {

    func present()
    func handle(_ event: AMMsPresenterEvent)
}

// MARK: - DefaultAMMsPresenter

class DefaultAMMsPresenter {

    private let interactor: AMMsInteractor
    private let wireframe: AMMsWireframe

    // private var items: [Item]

    private weak var view: AMMsView?

    init(
        view: AMMsView,
        interactor: AMMsInteractor,
        wireframe: AMMsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: AMMsPresenter

extension DefaultAMMsPresenter: AMMsPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: AMMsPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultAMMsPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultAMMsPresenter {

//    func viewModel(from items: [Item], active: Item?) -> AMMsViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
