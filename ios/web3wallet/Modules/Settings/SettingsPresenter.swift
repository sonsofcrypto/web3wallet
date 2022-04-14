// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SettingsPresenterEvent {
    case didSelectItemAt(idx: Int)
}

protocol SettingsPresenter {

    func present()
    func handle(_ event: SettingsPresenterEvent)
}

// MARK: - DefaultSettingsPresenter

class DefaultSettingsPresenter {

    private let interactor: SettingsInteractor
    private let wireframe: SettingsWireframe

    private var items: [Setting] = []
    private var currViewModel: SettingsViewModel = .init(items: [])

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
        self.items = interactor.settings()
        view?.update(with: viewModel())
    }

    func handle(_ event: SettingsPresenterEvent) {
        switch event {
        case let .didSelectItemAt(idx):
            handleDidSelectItem(at: idx)
        }
    }
}

// MARK: - Event handling

private extension DefaultSettingsPresenter {

    func handleDidSelectItem(at idx: Int) {
        switch currViewModel.items[idx].type {
        case .setting:
            wireframe.navigate(to: .settingOptions(setting: items[idx]))
        case .action:
            try? interactor.resetKeyStore()
            fatalError("Killing up on purpose after keystore reset")
        }
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultSettingsPresenter {

    func updateView(with viewModel: SettingsViewModel) {
        self.currViewModel = viewModel
        view?.update(with: viewModel)
    }

    func viewModel() -> SettingsViewModel {
        .init(
            items: items.map {
                .init(
                    title: $0.rawValue,
                    type: .setting,
                    selectedValue: interactor.currentValue(for: $0)
                )
            } + [
                .init(
                    title: "Reset all data",
                    type: .action,
                    selectedValue: nil
                )
            ]
        )

    }
}
