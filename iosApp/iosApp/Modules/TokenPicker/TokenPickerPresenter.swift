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
    private var currencies = [Web3Token]()
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
            
            guard let token = currencies.filter({ $0.symbol == token.symbol }).first else { return }
            wireframe.navigate(to: .tokenDetails(token))
            
        case .dismiss:
            
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenPickerPresenter {
    
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
        
        networks = interactor.allNetworks
        
        var filters: [TokenPickerViewModel.Filter] = [
            .init(
                type: .all(name: Localized("tokenPicker.networks.all")),
                isSelected: selectedNetworks.isEmpty
            )
        ]
        let networkFilters: [TokenPickerViewModel.Filter] = networks.compactMap { network in
            
            let isNetworkSelected = (selectedNetworks.first { $0.name == network.name }) != nil
            return .init(
                type: .item(icon: network.icon, name: network.name),
                isSelected: isNetworkSelected
            )
        }
        filters.append(contentsOf: networkFilters)
        return filters
    }
    
    func makeEmptySearchItems() -> [TokenPickerViewModel.Item] {
        
        let currencies = interactor.tokens(matching: "")
        self.currencies = currencies
        
        let featuredCurrencies = currencies.filter { shouldAddToken($0) && $0.type == .featured }
        let popularCurrencies = currencies.filter { shouldAddToken($0) && $0.type == .popular }
        let otherCurrencies = currencies.filter { shouldAddToken($0) && $0.type != .popular }
        
        var items = [TokenPickerViewModel.Item]()
        
        if !featuredCurrencies.isEmpty {
            
            items.append(
                .group(
                    .init(
                        name: Localized("tokenPicker.featured.title")
                    )
                )
            )
            let featuredItems: [TokenPickerViewModel.Item] = featuredCurrencies.compactMap {
                .token(
                    .init(
                        image: $0.image?.pngImage ?? .init(named: "default_currency")!,
                        symbol: $0.symbol,
                        name: $0.name,
                        network: $0.network.name
                    )
                )
            }
            items.append(contentsOf: featuredItems)
        }
        
        if !popularCurrencies.isEmpty {
            
            items.append(
                .group(
                    .init(
                        name: Localized("tokenPicker.popular.title")
                    )
                )
            )
            let popularItems: [TokenPickerViewModel.Item] = popularCurrencies.compactMap {
                .token(
                    .init(
                        image: $0.image?.pngImage ?? .init(named: "default_currency")!,
                        symbol: $0.symbol,
                        name: $0.name,
                        network: $0.network.name
                    )
                )
            }
            items.append(contentsOf: popularItems)
        }
        
        if !otherCurrencies.isEmpty {
            
            items.append(
                .group(
                    .init(
                        name: Localized("tokenPicker.all.title")
                    )
                )
            )
            let allItems: [TokenPickerViewModel.Item] = otherCurrencies.compactMap {
                .token(
                    .init(
                        image: $0.image?.pngImage ?? .init(named: "default_currency")!,
                        symbol: $0.symbol,
                        name: $0.name,
                        network: $0.network.name
                    )
                )
            }
            items.append(contentsOf: allItems)
        }
        
        if items.isEmpty {
            
            items.append(.group(.init(name: Localized("tokenPicker.noResults"))))
        }
        
        return items
    }
    
    func makeSearchItems(for searchTerm: String) -> [TokenPickerViewModel.Item] {
        
        let currencies = interactor.tokens(matching: searchTerm).filter {
            shouldAddToken($0)
        }
        self.currencies = currencies
        
        var items: [TokenPickerViewModel.Item] = currencies.compactMap {
            .token(
                .init(
                    image: $0.image?.pngImage ?? .init(named: "default_currency")!,
                    symbol: $0.symbol,
                    name: $0.name,
                    network: $0.network.name
                )
            )
        }
        
        if items.isEmpty {
            
            items.append(.group(.init(name: Localized("tokenPicker.noResults"))))
        }
        
        return items
    }
}

private extension DefaultTokenPickerPresenter {
    
    func filterSelected(_ filter: TokenPickerViewModel.Filter) {
        
        switch filter.type {
            
        case .all:
            
            selectedNetworks = []
            refreshData()
            
        case let .item(_, name):
            
            guard let networkSelected = networks.first(where: { $0.name == name }) else { return }
            
            let isNetworkSelected = selectedNetworks.first { $0.name == name } != nil
            
            if isNetworkSelected {
                
                selectedNetworks.removeAll { $0.name == name }
            } else {
                
                selectedNetworks.append(networkSelected)
            }
            
            refreshData()
        }
    }
    
    func shouldAddToken(_ token: Web3Token) -> Bool {
        
        guard !selectedNetworks.isEmpty else { return true }
        
        return selectedNetworks.first { $0.name == token.network.name } != nil
    }
}
