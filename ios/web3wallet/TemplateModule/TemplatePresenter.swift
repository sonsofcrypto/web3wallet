// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TemplatePresenterEvent {

}

protocol TemplatePresenter {

    func present()
    func handle(_ event: TemplatePresenterEvent)
}

// MARK: - DefaultTemplatePresenter

class DefaultTemplatePresenter {

    private let interactor: TemplateInteractor
    private let wireframe: TemplateWireframe

    private var items: [Item]

    private weak var view: TemplateView?

    init(
        view: TemplateView,
        interactor: TemplateInteractor,
        wireframe: TemplateWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.items = []
    }
}

// MARK: TemplatePresenter

extension DefaultTemplatePresenter: TemplatePresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: TemplatePresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultTemplatePresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultTemplatePresenter {

    func viewModel(from items: [Item], active: Item?) -> TemplateViewModel {
        .loaded(
            wallets: viewModel(from: wallets),
            selectedIdx: selectedIdx(wallets, active: active)
        )
    }
}
