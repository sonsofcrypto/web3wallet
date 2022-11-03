// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AppsPresenterEvent {
    case itemSelectedAt(index: Int)
}

protocol AppsPresenter {
    func present()
    func handle(_ event: AppsPresenterEvent)
}

final class DefaultAppsPresenter {
    private weak var view: AppsView?
    private let interactor: AppsInteractor
    private let wireframe: AppsWireframe
    
    private var items: [AppItem] = []

    init(
        view: AppsView,
        wireframe: AppsWireframe,
        interactor: AppsInteractor
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
    }
}

extension DefaultAppsPresenter: AppsPresenter {

    func present() {
        view?.update(with: .loading)
        interactor.fetchApps() { [weak self] result in
            guard let self = self else { return }
            self.processResponse(result: result)
        }
    }

    func handle(_ event: AppsPresenterEvent) {
        switch event {
        case let .itemSelectedAt(index):
            guard index < items.count else { return }
            let item = items[index]
            navigateToItem(item)
        }
    }
}

private extension DefaultAppsPresenter {
    
    func processResponse(
        result: Result<[AppItem], Error>
    ) {
        switch result {
        case let .success(items):
            self.items = items
            var items: [AppsViewModel.Item] = items.compactMap {
                switch $0 {
                case .chat:
                    return .init(title: Localized("chat.item.web3chat"))
                }
            }
            items.insert(
                .init(title: Localized("chat.colletion.top.cell.body")),
                at: 0
            )
            view?.update(with: .loaded(items: items, selectedIdx: 0))
        case .failure:
            // NOTE: This will never fail for now since data is mocked
            break
        }
    }
    
    func navigateToItem(_ item: AppItem) {
        switch item {
        case .chat:
            wireframe.navigate(to: .chat)
        }
    }
}
