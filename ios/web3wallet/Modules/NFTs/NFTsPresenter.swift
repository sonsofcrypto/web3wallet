//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

enum NFTsPresenterEvent {

}

protocol NFTsPresenter {

    func present()
    func handle(_ event: NFTsPresenterEvent)
}

// MARK: - DefaultNFTsPresenter

class DefaultNFTsPresenter {

    private let interactor: NFTsInteractor
    private let wireframe: NFTsWireframe

    // private var items: [Item]

    private weak var view: NFTsView?

    init(
        view: NFTsView,
        interactor: NFTsInteractor,
        wireframe: NFTsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: NFTsPresenter

extension DefaultNFTsPresenter: NFTsPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: NFTsPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultNFTsPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultNFTsPresenter {

//    func viewModel(from items: [Item], active: Item?) -> NFTsViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
