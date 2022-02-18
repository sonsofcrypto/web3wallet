// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DashboardPresenterEvent {

}

protocol DashboardPresenter {

    func present()
    func handle(_ event: DashboardPresenterEvent)
}

// MARK: - DefaultDashboardPresenter

class DefaultDashboardPresenter {

    private let interactor: DashboardInteractor
    private let wireframe: DashboardWireframe

    private weak var view: DashboardView?

    init(
        view: DashboardView,
        interactor: DashboardInteractor,
        wireframe: DashboardWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: DashboardPresenter

extension DefaultDashboardPresenter: DashboardPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: DashboardPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultDashboardPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultDashboardPresenter {

//    func viewModel(from items: [Item], active: Item?) -> DashboardViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
