// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DegenPresenterEvent {

}

protocol DegenPresenter {

    func present()
    func handle(_ event: DashboardPresenterEvent)
}

// MARK: - DefaultDegenPresenter

class DefaultDegenPresenter {

    private let interactor: DegenInteractor
    private let wireframe: DashboardWireframe

    private weak var view: DegenView?

    init(
        view: DegenView,
        interactor: DegenInteractor,
        wireframe: DashboardWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: DegenPresenter

extension DefaultDegenPresenter: DashboardPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: DashboardPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultDegenPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultDegenPresenter {


}
