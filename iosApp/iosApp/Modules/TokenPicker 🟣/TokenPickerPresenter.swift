// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum TokenPickerPresenterEvent {
    case search(searchTerm: String)
    case selectNetwork(TokenPickerViewModel.Network)
    case selectCurrency(TokenPickerViewModel.Currency)
    case addCustomCurrency
    case done
    case dismiss
}

protocol TokenPickerPresenter {
    func present()
    func handle(_ event: TokenPickerPresenterEvent)
}

final class DefaultTokenPickerPresenter {
    private weak var view: TokenPickerView?
    private let wireframe: TokenPickerWireframe
    private let interactor: TokenPickerInteractor
    private let context: TokenPickerWireframeContext
    
    private var searchTerm: String = ""
    private var selectedNetwork: Network!
    private var networks: [Network] = []
    private var selectedCurrencies: [Currency] = []
    private var selectedCurrenciesFiltered: [Currency] = []
    private var currencies = [Currency]()
    private var currenciesFiltered = [Currency]()

    init(
        view: TokenPickerView,
        wireframe: TokenPickerWireframe,
        interactor: TokenPickerInteractor,
        context: TokenPickerWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultTokenPickerPresenter: TokenPickerPresenter {

    func present() {
        loadSelectedNetworksIfNeeded()
        loadSelectedTokensIfNeeded()
        refreshCurrencies()
        refreshData()
    }

    func handle(_ event: TokenPickerPresenterEvent) {
        switch event {
        case let .search(searchTerm):
            self.searchTerm = searchTerm
            refreshData()
        case let .selectNetwork(network):
            guard let network = findSelectedNetwork(from: network) else { return }
            selectedNetwork = network
            selectedCurrencies = interactor.myCurrencies(for: selectedNetwork)
            refreshCurrencies()
            refreshData()
        case let .selectCurrency(currency):
            switch context.source {
            case .multiSelectEdit:
                handleCurrencyTappedOnMultiSelect(currency: currency)
            case let .select(onCompletion):
                guard let currency = findSelectedCurrency(from: currency) else { return }
                onCompletion(selectedNetwork, currency)
            }
        case .addCustomCurrency:
            guard let network = networks.first else { return }
            wireframe.navigate(to: .addCustomCurrency(network: network))
        case .done:
            wireframe.dismiss()
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenPickerPresenter {
    
    func onMultiSelectCurrenciesChanged() {
        guard
            case let TokenPickerWireframeContext.Source.multiSelectEdit(_, onCompletion) = context.source
        else { return }
        onCompletion(selectedCurrencies)
    }
    
    func loadSelectedNetworksIfNeeded() {
        networks = loadNetworks()
        if let selectedNetwork = context.selectedNetwork, networks.contains(selectedNetwork) {
            self.selectedNetwork = selectedNetwork
        } else {
            selectedNetwork = networks[0]
        }
    }
    
    func loadNetworks() -> [Network] {
        switch context.networks {
        case .all: return interactor.supportedNetworks
        case let .subgroup(networks): return networks
        }
    }
    
    func loadSelectedTokensIfNeeded() {
        switch context.source {
        case let .multiSelectEdit(selectedCurrencies, _):
            self.selectedCurrencies = selectedCurrencies
        default:
            selectedCurrencies = interactor.myCurrencies(for: selectedNetwork)
        }
    }
    
    func handleCurrencyTappedOnMultiSelect(currency: TokenPickerViewModel.Currency) {
        if let currency = selectedCurrenciesFiltered.findCurrency(matching: currency.id) {
            selectedCurrencies = selectedCurrencies.removingCurrency(id: currency.id())
        } else if let currency = currenciesFiltered.findCurrency(matching: currency.id) {
            selectedCurrencies = selectedCurrencies.addingCurrency(currency)
        }
        onMultiSelectCurrenciesChanged()
        refreshData()
    }
    
    func findSelectedNetwork(from network: TokenPickerViewModel.Network) -> Network? {
        networks.first { $0.id() == network.networkId }
    }
    
    func findSelectedCurrency(from currency: TokenPickerViewModel.Currency) -> Currency? {
        if let currency = selectedCurrenciesFiltered.findCurrency(matching: currency.id) {
            return currency
        } else if let currency = currenciesFiltered.findCurrency(matching: currency.id) {
            return currency
        } else {
            return nil
        }
    }
    
    func refreshCurrencies() {
        currencies = interactor.currencies(
            filteredBy: searchTerm,
            for: selectedNetwork
        )
    }
    
    func refreshData() {
        selectedCurrenciesFiltered = selectedCurrencies.filterBy(
            searchTerm: searchTerm
        )
        currenciesFiltered = interactor.currencies(
            filteredBy: searchTerm,
            for: selectedNetwork
        )
        updateView(with: sectionsToDisplay())
    }
    
    func updateView(with sectionsDisplayed: [TokenPickerViewModel.Section]) {
        let viewModel = viewModel(with: sectionsDisplayed)
        view?.update(with: viewModel)
    }
    
    func viewModel(with sectionsDisplayed: [TokenPickerViewModel.Section]) -> TokenPickerViewModel {
        .init(
            title: Localized("tokenPicker.title.\(context.title.rawValue)"),
            allowMultiSelection: context.source.isMultiSelect,
            showAddCustomCurrency: context.showAddCustomCurrency,
            content: .loaded(sections: sectionsDisplayed)
        )
    }
    
    func sectionsToDisplay() -> [TokenPickerViewModel.Section] {
        var sections = [TokenPickerViewModel.Section]()
        if networks.count > 1 {
            sections.append(
                .init(
                    name: Localized("tokenPicker.networks.title"),
                    type: .networks,
                    items: viewModelNetworks()
                )
            )
        }
        if !selectedCurrenciesFiltered.isEmpty {
            sections.append(
                .init(
                    name: Localized("tokenPicker.myTokens.title"),
                    type: .tokens,
                    items: myViewModelCurrencies(from: selectedCurrenciesFiltered)
                )
            )
        }
        if !currenciesFiltered.isEmpty {
            sections.append(
                .init(
                    name: Localized("tokenPicker.other.title"),
                    type: .tokens,
                    items: otherViewModelCurrencies(from: currenciesFiltered)
                )
            )
        }
        return sections.addNoResultsIfNeeded
    }
}

private extension DefaultTokenPickerPresenter {
    
    func viewModelNetworks() -> [TokenPickerViewModel.Item] {
        networks.compactMap {
            .network(
                .init(
                    networkId: $0.id(),
                    iconName: $0.iconName,
                    name: $0.name,
                    isSelected: $0.id() == selectedNetwork.id()
                )
            )
        }
    }
    
    func myViewModelCurrencies(from currencies: [Currency]) -> [TokenPickerViewModel.Item] {
        currencies.compactMap { currency in
            let currencyBalance = interactor.balance(for: currency, network: selectedNetwork)
            let fiatBalancce = currency.fiatValue(for: currencyBalance)
            let type: TokenPickerViewModel.TokenType
            switch context.source {
            case .multiSelectEdit:
                let isSelected = selectedCurrenciesFiltered.contains(
                    where: {
                        $0.symbol == currency.symbol
                    }
                )
                type = .init(
                    isSelected: isSelected,
                    balance: .init(
                        tokens: Formatter.currency.string(
                            currencyBalance,
                            currency: currency,
                            style: .long
                        ),
                        usdTotal: Formatter.fiat.string(fiatBalancce)
                    )
                )
            case .select:
                type = .init(
                    isSelected: nil,
                    balance: .init(
                        tokens: Formatter.currency.string(
                            currencyBalance,
                            currency: currency,
                            style: .long
                        ),
                        usdTotal: Formatter.fiat.string(fiatBalancce)
                    )
                )
            }
            let position: TokenPickerViewModel.Currency.Position
            if currencies.first == currency && currencies.last == currency {
                position = .onlyOne
            } else if currencies.first == currency {
                position = .first
            } else if currencies.last == currency {
                position = .last
            } else {
                position = .middle
            }
            return .currency(
                .init(
                    id: currency.coinGeckoId ?? "",
                    imageName: currency.iconName,
                    symbol: currency.symbol,
                    name: currency.name,
                    type: type,
                    position: position
                )
            )
        }
    }
    
    func otherViewModelCurrencies(from currencies: [Currency]) -> [TokenPickerViewModel.Item] {
        currencies.compactMap { currency in
            let type: TokenPickerViewModel.TokenType
            switch context.source {
            case .select:
                type = .init(
                    isSelected: nil,
                    balance: nil
                )
            case .multiSelectEdit:
                let isSelected = selectedCurrenciesFiltered.contains{
                    $0.symbol == currency.symbol
                }
                type = .init(
                    isSelected: isSelected,
                    balance: nil
                )
            }
            let position: TokenPickerViewModel.Currency.Position
            if currencies.first == currency && currencies.last == currency {
                position = .onlyOne
            } else if currencies.first == currency {
                position = .first
            } else if currencies.last == currency {
                position = .last
            } else {
                position = .middle
            }
            return .currency(
                .init(
                    id: currency.coinGeckoId ?? "",
                    imageName: currency.iconName,
                    symbol: currency.symbol,
                    name: currency.name,
                    type: type,
                    position: position
                )
            )
        }
    }
}

private extension Array where Element == Network {
    
    func hasNetwork(matching name: String) -> Bool {
        findNetwork(matching: name) != nil
    }
    
    func findNetwork(matching name: String) -> Network? {
        filter { $0.name == name }.first
    }
}

private extension Array where Element == Currency {

    func addingCurrency(_ currency: Currency) -> [Currency] {
        var currencies = self
        currencies.append(currency)
        return currencies
    }
    
    func removingCurrency(id: String) -> [Currency] {
        var currencies = self
        currencies.removeAll {
            $0.coinGeckoId == id
        }
        return currencies
    }
    
    func removingCurrencies(matching currencies: [Currency]) -> [Currency] {
        let ids = currencies.compactMap { $0.coinGeckoId }
        return filter { !ids.contains($0.coinGeckoId ?? "") }
    }
    
    func hasCurrency(with symbol: String) -> Bool {
        findCurrency(with: symbol) != nil
    }
    
    func findCurrency(with symbol: String) -> Currency? {
        filter { $0.symbol == symbol }.first
    }
    
    func findCurrency(matching id: String) -> Currency? {
        
        filter { $0.coinGeckoId == id }.first
    }
}

private extension Array where Element == TokenPickerViewModel.Section {
    
    var addNoResultsIfNeeded: [TokenPickerViewModel.Section] {
        guard isEmpty else { return self }
        return [
            .init(
                name: Localized("tokenPicker.noResults"),
                type: .tokens,
                items: []
            )
        ]
    }
}
