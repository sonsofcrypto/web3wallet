// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenPickerPresenterEvent {

    case search(searchTerm: String)
    case selectFilter(TokenPickerViewModel.Filter)
    case selectItem(TokenPickerViewModel.Token)
    case dismiss
}

protocol TokenPickerPresenter {

    func present()
    func handle(_ event: TokenPickerPresenterEvent)
}

final class DefaultTokenPickerPresenter {

    private weak var view: TokenPickerView?
    private let interactor: TokenPickerInteractor
    private let wireframe: TokenPickerWireframe
    private let context: TokenPickerWireframeContext
    
    private var searchTerm: String = ""
    private var networks = [Web3Network]()
    private var selectedNetworks = [Web3Network]()
    private var tokens = [Web3Token]()
    private var itemsDisplayed = [TokenPickerViewModel.Item]()

    init(
        view: TokenPickerView,
        interactor: TokenPickerInteractor,
        wireframe: TokenPickerWireframe,
        context: TokenPickerWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultTokenPickerPresenter: TokenPickerPresenter {

    func present() {

        refreshTokens()
        refreshData()
    }

    func handle(_ event: TokenPickerPresenterEvent) {

        switch event {
            
        case let .search(searchTerm):
            
            self.searchTerm = searchTerm
            refreshData()
            
        case let .selectFilter(filter):
            
            filterSelected(filter)
            refreshData()
            
        case let .selectItem(token):
            
            guard let token = tokens.findToken(matching: token.symbol) else { return }
            wireframe.navigate(to: .tokenDetails(token))
            
        case .dismiss:
            
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenPickerPresenter {
    
    func refreshTokens() {
        
        // Get all available networks
        networks = interactor.allNetworks
        // Get all available tokens
        tokens = interactor.allTokens
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
    
    func makeViewModel() -> TokenPickerViewModel {
        
        .init(
            title: Localized("tokenPicker.title.\(context.source.rawValue)"),
            content: .loaded(filters: makeFilters(), items: itemsDisplayed)
        )
    }
    
    func makeFilters() -> [TokenPickerViewModel.Filter] {
        
        var filters: [TokenPickerViewModel.Filter] = [
            .init(
                type: .all(name: Localized("tokenPicker.networks.all")),
                isSelected: selectedNetworks.isEmpty
            )
        ]
        let networkFilters: [TokenPickerViewModel.Filter] = networks.compactMap {
            
            .init(
                type: .item(
                    icon: interactor.networkIcon(for: $0),
                    name: $0.name
                ),
                isSelected: selectedNetworks.hasNetwork(matching: $0.name)
            )
        }
        filters.append(contentsOf: networkFilters)
        return filters
    }
    
    func makeEmptySearchItems() -> [TokenPickerViewModel.Item] {
        
        let tokens = tokens.filteredBy(searchTerm: searchTerm, networkIn: selectedNetworks)
        
        var featuredTokens = [Web3Token]()
        var popularTokens = [Web3Token]()
        var otherTokens = [Web3Token]()
        
        tokens.forEach {
            
            switch $0.type {
            case .featured:
                featuredTokens.append($0)
            case .popular:
                popularTokens.append($0)
            case .normal:
                otherTokens.append($0)
            }
        }
        
        var items = [TokenPickerViewModel.Item]()
        
        let featuredGroupName = Localized("tokenPicker.featured.title")
        items.append(contentsOf: makeItems(with: featuredGroupName, and: featuredTokens))

        let popularGroupName = Localized("tokenPicker.popular.title")
        items.append(contentsOf: makeItems(with: popularGroupName, and: popularTokens))

        let allGroupName = Localized("tokenPicker.all.title")
        items.append(contentsOf: makeItems(with: allGroupName, and: otherTokens))

        return items.addNoResultsIfNeeded
    }
    
    func makeSearchItems(for searchTerm: String) -> [TokenPickerViewModel.Item] {
        
        let tokens = tokens.filteredBy(searchTerm: searchTerm, networkIn: selectedNetworks)
        return tokens.items(using: interactor).addNoResultsIfNeeded
    }
}

private extension DefaultTokenPickerPresenter {
    
    func filterSelected(_ filter: TokenPickerViewModel.Filter) {
        
        switch filter.type {
            
        case .all:
            
            selectedNetworks = []
            refreshData()
            
        case let .item(_, name):
            
            guard let networkSelected = networks.findNetwork(matching: name) else { return }
            
            if selectedNetworks.hasNetwork(matching: name) {
                
                selectedNetworks.removeAll { $0.name == name }
            } else {
                
                selectedNetworks.append(networkSelected)
            }
            
            refreshData()
        }
    }
    
    func shouldAddToken(_ token: Web3Token) -> Bool {
        
        selectedNetworks.hasNetwork(matching: token.network.name)
    }
    
    func makeItems(with groupName: String, and tokens: [Web3Token]) -> [TokenPickerViewModel.Item] {
        
        guard !tokens.isEmpty else { return [] }
        
        var items = [TokenPickerViewModel.Item]()
        items.append(
            .group(
                .init(name: groupName)
            )
        )
        items.append(contentsOf: tokens.items(using: interactor))
        return items
    }
}

private extension Array where Element == Web3Network {
    
    func hasNetwork(matching name: String) -> Bool {
        
        findNetwork(matching: name) != nil
    }
    
    func findNetwork(matching name: String) -> Web3Network? {
        
        filter { $0.name == name }.first
    }
}

private extension Array where Element == Web3Token {
    
    func items(using interactor: TokenPickerInteractor) -> [TokenPickerViewModel.Item] {
        compactMap {
            .token(
                .init(
                    image: interactor.tokenIcon(for: $0).pngImage ?? .init(named: "default_token")!,
                    symbol: $0.symbol,
                    name: $0.name,
                    network: $0.network.name
                )
            )
        }
    }
    
    func filteredBy(searchTerm: String, networkIn selectedNetworks: [Web3Network]) -> [ Web3Token ] {
        
        filter {
            
            let searchTermMatching =
                $0.name.capitalized.hasPrefix(searchTerm.capitalized) ||
                $0.symbol.capitalized.hasPrefix(searchTerm.capitalized)
            
            let condition1 = searchTerm.isEmpty ? true : searchTermMatching
            
            let condition2 = selectedNetworks.isEmpty ? true : selectedNetworks.hasNetwork(
                matching: $0.network.name
            )
            
            return condition1 && condition2
        }
    }
    
    func findToken(matching symbol: String) -> Web3Token? {
        
        filter { $0.symbol == symbol }.first
    }
}

private extension Array where Element == TokenPickerViewModel.Item {
    
    var addNoResultsIfNeeded: [TokenPickerViewModel.Item] {
        
        guard isEmpty else { return self }
        
        return [
            .group(.init(name: Localized("tokenPicker.noResults")))
        ]
    }
}
