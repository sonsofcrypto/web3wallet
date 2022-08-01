// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SettingsPresenterEvent {
    
    case dismiss
    case didSelect(setting: Setting)
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
        
        updateView(with: viewModel())
    }

    func handle(_ event: SettingsPresenterEvent) {
        
        switch event {
            
        case .dismiss:
            wireframe.navigate(to: .dismiss)
            
        case let .didSelect(setting):
            
            switch setting.type {
                
            case let .item(identifier):
                
                let groups = interactor.settings(for: identifier)
                let context = SettingsWireframeContext(
                    title: setting.title,
                    groups: groups
                )
                wireframe.navigate(to: .settings(context: context))
                
            case let .action(item, action, _):
                
                interactor.didSelect(
                    item: item,
                    action: action
                )
                present()
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
            sections: makeSections()
        )
    }
    
    func makeSections() -> [SettingsViewModel.Section] {
        
        var sections = [SettingsViewModel.Section]()
        context.groups.forEach {
            
            if let title = $0.title {
                
                sections.append(
                    .header(header: .init(title: title))
                )
            }
            
            sections.append(makeSectionItems(for: $0))
        }
        return sections
    }
    
    func makeSectionItems(for group: SettingsWireframeContext.Group) -> SettingsViewModel.Section {
        
        .group(
            items: group.items.compactMap {
                .init(
                    title: $0.title,
                    setting: $0,
                    isSelected: isTypeSelected($0.type)
                )
            }
        )
    }
    
    func isTypeSelected(
        _ type: Setting.`Type`
    ) -> Bool {
        
        guard case let Setting.`Type`.action(item, action, _) = type else { return false }
        
        guard let item = item else { return false }
        
        return interactor.isSelected(
            item: item,
            action: action
        )
    }
}
