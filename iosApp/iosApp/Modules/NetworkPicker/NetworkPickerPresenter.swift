// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum NetworkPickerPresenterEvent {
    case search(searchTerm: String)
    case selectItem(NetworkPickerViewModel.Item)
    case dismiss
}

protocol NetworkPickerPresenter {
    func present()
    func handle(_ event: NetworkPickerPresenterEvent)
}

final class DefaultNetworkPickerPresenter {

    private weak var view: NetworkPickerView?
    private let wireframe: NetworkPickerWireframe
    private let interactor: NetworkPickerInteractor
    private let context: NetworkPickerWireframeContext
    
    private var searchTerm: String = ""
    private var networks = [Network]()
    private var itemsDisplayed = [NetworkPickerViewModel.Item]()

    init(
        view: NetworkPickerView,
        wireframe: NetworkPickerWireframe,
        interactor: NetworkPickerInteractor,
        context: NetworkPickerWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultNetworkPickerPresenter: NetworkPickerPresenter {

    func present() {
        refreshNetworks()
        refreshData()
    }

    func handle(_ event: NetworkPickerPresenterEvent) {
        switch event {
        case let .search(searchTerm):
            self.searchTerm = searchTerm
            refreshData()
        case let .selectItem(network):
            guard let network = networks.findNetwork(matching: network.name) else { return }
            wireframe.navigate(to: .select(network))
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultNetworkPickerPresenter {
    
    func refreshNetworks() {
        networks = interactor.allNetworks
    }
    
    func refreshData() {
        if searchTerm.isEmpty {
            itemsDisplayed = makeEmptySearchItems()
        } else {
            itemsDisplayed = makeSearchItems(for: searchTerm)
        }
        updateView()
    }
    
    func updateView() {
        let viewModel = makeViewModel()
        view?.update(with: viewModel)
    }
    
    func makeViewModel() -> NetworkPickerViewModel {
        .init(
            title: Localized("networkPicker.title"),
            items: itemsDisplayed
        )
    }
    
    func makeEmptySearchItems() -> [NetworkPickerViewModel.Item] {
        makeItems(from: networks)
    }
    
    func makeSearchItems(for searchTerm: String) -> [NetworkPickerViewModel.Item] {
        let networks = networks.filter { $0.name.lowercased().hasPrefix(searchTerm.lowercased()) }
        return makeItems(from: networks).addNoResultsIfNeeded
    }
}

private extension DefaultNetworkPickerPresenter {
        
    func makeItems(
        from networks: [Network]
    ) -> [NetworkPickerViewModel.Item] {
        networks.sortByName.compactMap {
            .init(
                imageName: $0.iconName,
                name: $0.name
            )
        }
    }
}

private extension Array where Element == Network {
    var sortByName: [Network] {
        sorted { $0.name < $1.name }
    }
    
    func findNetwork(matching name: String) -> Network? {
        filter { $0.name == name }.first
    }
}

private extension Array where Element == NetworkPickerViewModel.Item {
    var addNoResultsIfNeeded: [NetworkPickerViewModel.Item] {
        guard isEmpty else { return self }
        return [
            .init(imageName: nil, name: Localized("networkPicker.noResults"))
        ]
    }
}
