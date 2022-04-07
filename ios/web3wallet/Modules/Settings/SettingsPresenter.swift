//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

enum SettingsPresenterEvent {

}

protocol SettingsPresenter {

    func present()
    func handle(_ event: SettingsPresenterEvent)
}

// MARK: - DefaultSettingsPresenter

class DefaultSettingsPresenter {

    private let interactor: SettingsInteractor
    private let wireframe: SettingsWireframe

    private weak var view: SettingsView?

    init(
        view: SettingsView,
        interactor: SettingsInteractor,
        wireframe: SettingsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: SettingsPresenter

extension DefaultSettingsPresenter: SettingsPresenter {

    func present() {
        view?.update(with: .loading)
        // TODO: Interactor
    }

    func handle(_ event: SettingsPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultSettingsPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultSettingsPresenter {

//    func viewModel(from items: [Item], active: Item?) -> SettingsViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }
}
