// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum CurrencyPickerPresenterEvent {
    case search(searchTerm: String)
    case selectNetwork(CurrencyPickerViewModel.Network)
    case selectCurrency(CurrencyPickerViewModel.Currency)
    case addCustomCurrency
    case viewWillDismiss
    case done
    case dismiss
}

protocol CurrencyPickerPresenter {
    func present()
    func handle(_ event: CurrencyPickerPresenterEvent)
}

final class DefaultCurrencyPickerPresenter {
    private weak var view: CurrencyPickerView?
    private let wireframe: CurrencyPickerWireframe
    private let interactor: CurrencyPickerInteractor
    private let context: CurrencyPickerWireframeContext
    
    private var searchTerm: String = ""
    private var selectedNetwork: Network!
    private var networks: [Network] = []
    private var selectedCurrencies: [Currency] = []
    private var selectedCurrenciesFiltered: [Currency] = []
    private var currencies = [Currency]()
    private var currenciesFiltered = [Currency]()

    init(
        view: CurrencyPickerView,
        wireframe: CurrencyPickerWireframe,
        interactor: CurrencyPickerInteractor,
        context: CurrencyPickerWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultCurrencyPickerPresenter: CurrencyPickerPresenter {

    func present() {
        loadSelectedNetworksIfNeeded()
        loadSelectedCurrenciesIfNeeded()
        refreshCurrencies()
        refreshData()
    }

    func handle(_ event: CurrencyPickerPresenterEvent) {
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
        case .viewWillDismiss:
            guard
                case let CurrencyPickerWireframeContext.Source.multiSelectEdit(_, onCompletion) = context.source
            else { return }
            onCompletion(selectedCurrencies)
        case .done:
            wireframe.dismiss()
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultCurrencyPickerPresenter {
    
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
    
    func loadSelectedCurrenciesIfNeeded() {
        switch context.source {
        case let .multiSelectEdit(selectedCurrencies, _):
            self.selectedCurrencies = selectedCurrencies
        default:
            selectedCurrencies = interactor.myCurrencies(for: selectedNetwork)
        }
    }
    
    func handleCurrencyTappedOnMultiSelect(currency: CurrencyPickerViewModel.Currency) {
        if let currency = selectedCurrenciesFiltered.findCurrency(matching: currency.id) {
            selectedCurrencies = selectedCurrencies.removingCurrency(id: currency.id())
        } else if let currency = currenciesFiltered.findCurrency(matching: currency.id) {
            selectedCurrencies = selectedCurrencies.addingCurrency(currency)
        }
        refreshData()
    }
    
    func findSelectedNetwork(from network: CurrencyPickerViewModel.Network) -> Network? {
        networks.first { $0.id() == network.networkId }
    }
    
    func findSelectedCurrency(from currency: CurrencyPickerViewModel.Currency) -> Currency? {
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
    
    func updateView(with sectionsDisplayed: [CurrencyPickerViewModel.Section]) {
        let viewModel = viewModel(with: sectionsDisplayed)
        view?.update(with: viewModel)
    }
    
    func viewModel(with sectionsDisplayed: [CurrencyPickerViewModel.Section]) -> CurrencyPickerViewModel {
        .init(
            title: Localized("currencyPicker.title.\(context.title.rawValue)"),
            allowMultiSelection: context.source.isMultiSelect,
            showAddCustomCurrency: context.showAddCustomCurrency,
            content: .loaded(sections: sectionsDisplayed)
        )
    }
    
    func sectionsToDisplay() -> [CurrencyPickerViewModel.Section] {
        var sections = [CurrencyPickerViewModel.Section]()
        if networks.count > 1 {
            sections.append(
                .init(
                    name: Localized("currencyPicker.networks.title"),
                    type: .networks,
                    items: viewModelNetworks()
                )
            )
        }
        if !selectedCurrenciesFiltered.isEmpty {
            sections.append(
                .init(
                    name: Localized("currencyPicker.myTokens.title"),
                    type: .tokens,
                    items: myViewModelCurrencies(from: selectedCurrenciesFiltered)
                )
            )
        }
        if !currenciesFiltered.isEmpty {
            sections.append(
                .init(
                    name: Localized("currencyPicker.other.title"),
                    type: .tokens,
                    items: otherViewModelCurrencies(from: currenciesFiltered)
                )
            )
        }
        return sections.addNoResultsIfNeeded
    }
}

private extension DefaultCurrencyPickerPresenter {
    
    func viewModelNetworks() -> [CurrencyPickerViewModel.Item] {
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
    
    func myViewModelCurrencies(from currencies: [Currency]) -> [CurrencyPickerViewModel.Item] {
        currencies.compactMap { currency in
            let currencyBalance = interactor.balance(for: currency, network: selectedNetwork)
            let fiatBalancce = currency.fiatValue(for: currencyBalance)
            let type: CurrencyPickerViewModel.CurrencyType
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
                        tokens: Formatters.Companion.shared.currency.format(
                            amount: currencyBalance,
                            currency: currency,
                            style: Formatters.StyleCustom(maxLength: 15)
                        ),
                        usdTotal: Formatters.Companion.shared.fiat.format(
                            amount: fiatBalancce.bigDec,
                            style: Formatters.StyleCustom(maxLength: 10),
                            currencyCode: "usd"
                        )
                    )
                )
            case .select:
                type = .init(
                    isSelected: nil,
                    balance: .init(
                        tokens: Formatters.Companion.shared.currency.format(
                            amount: currencyBalance,
                            currency: currency,
                            style: Formatters.StyleCustom(maxLength: 15)
                        ),
                        usdTotal: Formatters.Companion.shared.fiat.format(
                            amount: fiatBalancce.bigDec,
                            style: Formatters.StyleCustom(maxLength: 10),
                            currencyCode: "usd"
                        )
                    )
                )
            }
            let position: CurrencyPickerViewModel.Currency.Position
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
    
    func otherViewModelCurrencies(from currencies: [Currency]) -> [CurrencyPickerViewModel.Item] {
        currencies.compactMap { currency in
            let type: CurrencyPickerViewModel.CurrencyType
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
            let position: CurrencyPickerViewModel.Currency.Position
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

private extension Array where Element == CurrencyPickerViewModel.Section {
    
    var addNoResultsIfNeeded: [CurrencyPickerViewModel.Section] {
        guard isEmpty else { return self }
        return [
            .init(
                name: Localized("currencyPicker.noResults"),
                type: .tokens,
                items: []
            )
        ]
    }
}
