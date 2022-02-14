// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NetworksPresenterEvent {

}

protocol NetworksPresenter {

    func present()
    func handle(_ event: NetworksPresenterEvent)
}

// MARK: - DefaultNetworksPresenter

class DefaultNetworksPresenter {

    private let interactor: NetworksInteractor
    private let wireframe: NetworksWireframe

    private var items: [Item]

    private weak var view: NetworksView?

    init(
        view: NetworksView,
        interactor: NetworksInteractor,
        wireframe: NetworksWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.items = []
    }
}

// MARK: NetworksPresenter

extension DefaultNetworksPresenter: NetworksPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: NetworksPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultNetworksPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultNetworksPresenter {

    func viewModel(from items: [Item], active: Item?) -> NetworksViewModel {
        .loaded(
            wallets: viewModel(from: wallets),
            selectedIdx: selectedIdx(wallets, active: active)
        )
    }
}
