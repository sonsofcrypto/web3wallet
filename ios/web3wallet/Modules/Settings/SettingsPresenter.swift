// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SettingsPresenterEvent {
    case didSelectItemAt(idxPath: IndexPath)
}

protocol SettingsPresenter {

    func present()
    func handle(_ event: SettingsPresenterEvent)
}

// MARK: - DefaultSettingsPresenter

class DefaultSettingsPresenter {

    private let interactor: SettingsInteractor
    private let wireframe: SettingsWireframe

    private var items: [SettingsItem] = []

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
        items = interactor.items
        updateView(with: viewModel())
    }

    func handle(_ event: SettingsPresenterEvent) {
        switch event {
        case let .didSelectItemAt(idxPath):
            handleDidSelectItem(at: idxPath)
        }
    }
}

// MARK: - Event handling

private extension DefaultSettingsPresenter {

    func handleDidSelectItem(at idxPath: IndexPath) {
//        switch currViewModel.items[idx].type {
//        case .setting:
//            wireframe.navigate(to: .settingOptions(setting: items[idx]))
//        case .action:
//            try? interactor.resetKeyStore()
//            fatalError("Killing up on purpose after keystore reset")
//        }
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultSettingsPresenter {

    func updateView(with viewModel: SettingsViewModel) {
        view?.update(with: viewModel)
    }

    func viewModel() -> SettingsViewModel {
        return .init(
            title: Localized("settings"),
            sections: items.map { topLevelItem in
                .init(
                    title: self.firstItemTitle(topLevelItem),
                    items: topLevelItem.isGroup()
                        ? topLevelItem.items().map { self.viewModel(for: $0) }
                        : [self.viewModel(for: topLevelItem)]
                )
            }
        )
    }

    func viewModel(for item: SettingsItem) -> SettingsViewModel.Item {
        switch item {
            case let .group(items, title):
                return .setting(title: Localized(title))
            case let .setting(setting):
                return .setting(title: Localized(setting.rawValue))
            case let .selectableOption(setting, optIdx, optTitle, selected):
                return .selectableOption(title: Localized(optTitle), selected: selected)
            case let .action(actionType):
                return .action(title: Localized(actionType.rawValue))
        }
    }

    func firstItemTitle(_ item: SettingsItem) -> String? {
        switch item {
        case let .group(_, title):
            return title
        default:
            return nil
        }
    }
}
