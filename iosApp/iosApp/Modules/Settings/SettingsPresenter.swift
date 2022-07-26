// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SettingsPresenterEvent {
    
    case dismiss
    case didSelectItemAt(idxPath: IndexPath)
}

protocol SettingsPresenter {

    func present()
    func handle(_ event: SettingsPresenterEvent)
}

final class DefaultSettingsPresenter {

    private weak var view: SettingsView?
    private let interactor: SettingsInteractor
    private let wireframe: SettingsWireframe
    private let context: SettingsWireframeContext

    private var items: [SettingsItem] = []

    init(
        view: SettingsView,
        interactor: SettingsInteractor,
        wireframe: SettingsWireframe,
        context: SettingsWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultSettingsPresenter: SettingsPresenter {

    func present() {
        
        items = context.settings
        updateView(with: viewModel())
    }

    func handle(_ event: SettingsPresenterEvent) {
        
        switch event {
            
        case .dismiss:
            wireframe.navigate(to: .dismiss)
            
        case let .didSelectItemAt(idxPath):
            handleDidSelectItem(at: idxPath)
        }
    }
}

private extension DefaultSettingsPresenter {

    func handleDidSelectItem(at idxPath: IndexPath) {
        
        switch item(at: idxPath) {
            
        case let .group(title, items):
            wireframe.navigate(to: .settings(title: title, settings: items))
            
        case let .setting(setting):
            let title = Localized(setting.rawValue)
            let items = interactor.settingsItem(for: setting)
            wireframe.navigate(to: .settings(title: title, settings: items))
            
        case let .selectableOption(setting, optIdx, _, _):
            interactor.didSelectSettingOption(at: optIdx, forSetting: setting)
            //items = interactor.items
            //updateView(with: viewModel())
            
        case let .action(actionType):
            if !interactor.handleActionIfPossible(actionType) {
                print("handle", actionType)
            }
        }
    }
}

private extension DefaultSettingsPresenter {

    func updateView(with viewModel: SettingsViewModel) {
        
        view?.update(with: viewModel)
    }

    func viewModel() -> SettingsViewModel {
        
        .init(
            title: context.title,
            sections: items.map { topLevelItem in
                .init(
                    title: firstItemTitle(topLevelItem),
                    items: topLevelItem.isGroup()
                        ? topLevelItem.items().map { self.viewModel(for: $0) }
                        : [viewModel(for: topLevelItem)]
                )
            }
        )
    }

    func viewModel(for item: SettingsItem) -> SettingsViewModel.Item {
        
        switch item {
            case let .group(title, _):
                return .setting(title: Localized(title))
            case let .setting(setting):
                return .setting(title: Localized(setting.rawValue))
            case let .selectableOption(_, _, optTitle, selected):
                return .selectableOption(title: Localized(optTitle), selected: selected)
            case let .action(actionType):
                return .action(title: Localized(actionType.rawValue))
        }
    }

    func firstItemTitle(_ item: SettingsItem) -> String? {
        
        switch item {
        case let .group(title, _):
            return title
        default:
            return nil
        }
    }

    func item(at idxPath: IndexPath) -> SettingsItem {

        switch items[idxPath.section] {
        case let .group(_, items):
            return items[idxPath.item]
        default:
            return items[idxPath.item]
        }
    }
}
