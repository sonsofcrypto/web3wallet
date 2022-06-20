// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

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
    private let interactor: NetworkPickerInteractor
    private let wireframe: NetworkPickerWireframe
    private let context: NetworkPickerWireframeContext
    
    private var searchTerm: String = ""
    private var networks = [Web3Network]()
    private var itemsDisplayed = [NetworkPickerViewModel.Item]()

    init(
        view: NetworkPickerView,
        interactor: NetworkPickerInteractor,
        wireframe: NetworkPickerWireframe,
        context: NetworkPickerWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
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

            guard let web3Network = networks.findNetwork(matching: network.name) else { return }
            wireframe.navigate(to: .select(web3Network))
                        
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
        from networks: [Web3Network]
    ) -> [NetworkPickerViewModel.Item] {
        
        networks.sortByName.compactMap {
            .init(
                image: interactor.networkIcon(for: $0).pngImage,
                name: $0.name
            )
        }
    }
}

private extension Array where Element == Web3Network {
    
    func findNetwork(matching name: String) -> Web3Network? {
        
        filter { $0.name == name }.first
    }
}

private extension Array where Element == NetworkPickerViewModel.Item {
    
    var addNoResultsIfNeeded: [NetworkPickerViewModel.Item] {
        
        guard isEmpty else { return self }
        
        return [
            .init(image: nil, name: Localized("networkPicker.noResults"))
        ]
    }
}
