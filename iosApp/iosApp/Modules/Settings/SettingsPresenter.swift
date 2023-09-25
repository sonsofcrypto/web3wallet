// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum SettingsPresenterEvent {

}

protocol SettingsPresenter {
    func present()
    func handle(_ event: SettingsPresenterEvent)
}

// MARK: - DefaultSettingsPresenter

class DefaultSettingsPresenter {
    private let interactor: SettingsInterator
    private let wireframe: SettingsWireframe

    // private var items: [Item]

    private weak var view: SettingsView?

    init(
        view: SettingsView,
        interactor: SettingsInterator,
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
        view?.update(with: viewModel())
    }

    func handle(_ event: SettingsPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultSettingsPresenter {

}

// MARK: - SettingsViewModel utilities

private extension DefaultSettingsPresenter {

    func viewModel() -> SettingsViewModel {
        .init(
            sections: [
                .init(
                    items: [
                        CellViewModel.Label(text: "Test 1", accessory: .none),
                        CellViewModel.Label(text: "Test 2", accessory: .none),
                        CellViewModel.Label(text: "Test 3", accessory: .none)
                    ]
                ),
                .init(
                    items: [
                        CellViewModel.Label(text: "Test 1", accessory: .none),
                        CellViewModel.Label(text: "Test 2", accessory: .none)
                    ]
                )
            ]
        )
    }
}
