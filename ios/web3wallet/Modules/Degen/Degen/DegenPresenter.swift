// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DegenPresenterEvent {
    case didSelectCategory(idx: Int)
}

protocol DegenPresenter {

    func present()
    func handle(_ event: DegenPresenterEvent)
}

// MARK: - DefaultDegenPresenter

class DefaultDegenPresenter {

    private let interactor: DegenInteractor
    private let wireframe: DegenWireframe

    private weak var view: DegenView?

    init(
        view: DegenView,
        interactor: DegenInteractor,
        wireframe: DegenWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: DegenPresenter

extension DefaultDegenPresenter: DegenPresenter {

    func present() {
        view?.update(with: viewModel(categories: interactor.categories()))
    }

    func handle(_ event: DegenPresenterEvent) {
        switch event {
        case let .didSelectCategory(idx):
            // TODO: Navigate to category
            ()
        }
    }
}

// MARK: - Event handling

private extension DefaultDegenPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultDegenPresenter {

    func viewModel(categories: [DAppCategory]) -> DegenViewModel {
        .init(
            sectionTitle: Localized("degen.section.title"),
            items: categories.map {
                .init(title: $0.title, subtitle: $0.subTitle)
            }
        )
    }
}
