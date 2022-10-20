// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

// MARK: - CurrencyAddPresenterEvent

enum CurrencyAddPresenterEvent {
    case selectNetwork
    case pasteInput(for: CurrencyAddViewModel.TextFieldType, to: String)
    case inputChanged(for: CurrencyAddViewModel.TextFieldType, to: String)
    case returnKeyTapped(for: CurrencyAddViewModel.TextFieldType)
    case addCurrency
    case dismiss
}

// MARK: - CurrencyAddPresenter

protocol CurrencyAddPresenter {
    func present()
    func handle(_ event: CurrencyAddPresenterEvent)
}

// MARK: - DefaultCurrencyAddPresenter

final class DefaultCurrencyAddPresenter {

    private weak var view: CurrencyAddView?
    private let wireframe: CurrencyAddWireframe
    private let interactor: CurrencyAddInteractor
    private let context: CurrencyAddWireframeContext
    
    private var network: Network!
    private var contractAddress: String?
    private var contractAddressValidationError: String?
    private var name: String?
    private var nameValidationError: String?
    private var symbol: String?
    private var symbolValidationError: String?
    private var decimals: String?
    private var decimalsValidationError: String?
    
    private var addTokenTapped = false
    
    init(
        view: CurrencyAddView,
        wireframe: CurrencyAddWireframe,
        interactor: CurrencyAddInteractor,
        context: CurrencyAddWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
        
        self.network = context.network
    }
}

extension DefaultCurrencyAddPresenter: CurrencyAddPresenter {

    func present() {
        refresh()
    }

    func handle(_ event: CurrencyAddPresenterEvent) {
        switch event {
        case .selectNetwork:
            wireframe.navigate(to: .selectNetwork(onCompletion: onNetworkSelected()))
        case let .pasteInput(type, value):
            pasteInput(for: type, to: value)
        case let .inputChanged(type, value):
            inputChanged(for: type, to: value)
        case let .returnKeyTapped(type):
            returnKeyTapped(for: type)
        case .addCurrency:
            handleAddToken()
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

// MARK: - Handlers

private extension DefaultCurrencyAddPresenter {
    
    func handleAddToken() {
        addTokenTapped = true
        validateFields()
        if areAllFieldsValid() {
            interactor.addCurrency(
                .init(
                    address: contractAddress ?? "",
                    name: name ?? "",
                    symbol: symbol ?? "",
                    decimals: Int(decimals ?? "0") ?? 0
                ),
                for: network
            ) { [weak self] in
                guard let self = self else { return }
                self.view?.dismissKeyboard()
                self.wireframe.dismiss()
            }
        } else {
            refresh()
        }
    }
}

// MARK: - ViewModel

private extension DefaultCurrencyAddPresenter {
    
    func refresh(
        firstResponder: CurrencyAddViewModel.TextFieldType? = nil
    ) {
        validateFields()
        view?.update(with: viewModel(firstResponder: firstResponder))
        // TODO: Fetch other contractAddress details async
        // if contractAddress is a valid one for the selected network
    }
    
    func viewModel(
        firstResponder: CurrencyAddViewModel.TextFieldType?
    ) -> CurrencyAddViewModel {
        .init(
            title: Localized("currencyAdd.title", context.network.name.capitalized),
            network: .init(
                name: Localized("currencyAdd.network.title"),
                value: network.name
            ),
            contractAddress: .init(
                name: Localized("currencyAdd.contractAddress.title"),
                value: formattedAddress ?? contractAddress,
                placeholder: Localized("currencyAdd.contractAddress.placeholder"),
                hint: addTokenTapped ? contractAddressValidationError : nil,
                tag: CurrencyAddViewModel.TextFieldType.contractAddress.rawValue,
                isFirstResponder: firstResponder == .contractAddress
            ),
            name: .init(
                name: Localized("currencyAdd.name.title"),
                value: name,
                placeholder: Localized("currencyAdd.name.placeholder"),
                hint: addTokenTapped ? nameValidationError : nil,
                tag: CurrencyAddViewModel.TextFieldType.name.rawValue,
                isFirstResponder: firstResponder == .name
            ),
            symbol: .init(
                name: Localized("currencyAdd.symbol.title"),
                value: symbol,
                placeholder: Localized("currencyAdd.symbol.placeholder"),
                hint: addTokenTapped ? symbolValidationError : nil,
                tag: CurrencyAddViewModel.TextFieldType.symbol.rawValue,
                isFirstResponder: firstResponder == .symbol
            ),
            decimals: .init(
                name: Localized("currencyAdd.decimals.title"),
                value: decimals,
                placeholder: Localized("currencyAdd.decimals.placeholder"),
                hint: addTokenTapped ? decimalsValidationError : nil,
                tag: CurrencyAddViewModel.TextFieldType.decimals.rawValue,
                isFirstResponder: firstResponder == .decimals
            ),
            saveButtonTitle: saveButtonTitle(),
            saveButtonEnabled: saveButtonTitle() == Localized("currencyAdd.cta.valid")
        )
    }
    
    var formattedAddress: String? {
        guard let address = contractAddress else { return nil }
        guard network.isValidAddress(input: address) else { return nil }
        return Formatters.Companion().networkAddress.format(address: address, digits: 10.int32, network: network)
    }
    
    func saveButtonTitle() -> String {
        let validTitle = Localized("currencyAdd.cta.valid")
        guard addTokenTapped else { return validTitle }
        guard contractAddressValidationError == nil else {
            return Localized("currencyAdd.cta.invalid.contractAddress")
        }
        guard nameValidationError == nil else {
            return Localized("currencyAdd.cta.invalid.name")
        }
        guard symbolValidationError == nil else {
            return Localized("currencyAdd.cta.invalid.symbol")
        }
        guard decimalsValidationError == nil else {
            return Localized("currencyAdd.cta.invalid.decimals")
        }
        guard areAllFieldsValid() else {
            return Localized("currencyAdd.cta.invalid")
        }
        return validTitle
    }
    
    func areAllFieldsValid() -> Bool {
        guard
            contractAddressValidationError == nil,
            nameValidationError == nil,
            symbolValidationError == nil,
            decimalsValidationError == nil
        else { return false }
        return true
    }
    
    func pasteInput(for type: CurrencyAddViewModel.TextFieldType, to value: String) {
        var value = value
        switch type {
        case .contractAddress: guard network.isValidAddress(input: value) else { return }
        case .name: break
        case .symbol: break
        case .decimals:
            guard let int = try? value.int() else { return }
            if int < 1 { value = 1.stringValue }
            else if int > 32 { value = 32.stringValue }
        }
        inputChanged(for: type, to: value)
    }
    
    func inputChanged(for type: CurrencyAddViewModel.TextFieldType, to value: String) {
        switch type {
        case .contractAddress: contractAddress = value
        case .name: name = value
        case .symbol: symbol = value
        case .decimals: decimals = value
        }
        refresh()
    }
    
    func returnKeyTapped(for type: CurrencyAddViewModel.TextFieldType) {
        switch type {
        case .contractAddress:
            refresh(firstResponder: .name)
        case .name:
            refresh(firstResponder: .symbol)
        case .symbol:
            refresh(firstResponder: .decimals)
        case .decimals:
            refresh(firstResponder: .contractAddress)
        }
    }

    func validateFields() {
        validateContractAddress()
        validateName()
        validateSymbol()
        validateDecimals()
    }

    func validateContractAddress() {
        guard !network.isValidAddress(input: contractAddress ?? "") else {
            contractAddressValidationError = nil
            return
        }
        contractAddressValidationError = Localized(
            "currencyAdd.validation.field.address.\(network.name.lowercased()).invalid"
        )
    }
        
    func validateName() {
        guard name?.isEmpty ?? true else {
            nameValidationError = nil
            return
        }
        nameValidationError = Localized("currencyAdd.validation.field.required")
    }

    func validateSymbol() {
        guard symbol?.isEmpty ?? true else {
            symbolValidationError = nil
            return
        }
        symbolValidationError = Localized("currencyAdd.validation.field.required")
    }

    func validateDecimals() {
        guard !(decimals?.isEmpty ?? true) else {
            decimalsValidationError = Localized("currencyAdd.validation.field.required")
            return
        }
        guard let intValue = try? decimals?.int() else {
            decimalsValidationError = Localized("currencyAdd.validation.field.decimal.int")
            return
        }
        guard 0 <= intValue, intValue <= 32 else {
            decimalsValidationError = Localized("currencyAdd.validation.field.decimal.range")
            return
        }
        decimalsValidationError = nil
    }
    
    func nextFirstResponder() -> CurrencyAddViewModel.TextFieldType? {
        validateFields()
        
        if contractAddressValidationError != nil {
            return .contractAddress
        } else if nameValidationError != nil {
            return .name
        } else if symbolValidationError != nil {
            return .symbol
        } else if decimalsValidationError != nil {
            return .decimals
        } else {
            view?.dismissKeyboard()
            return nil
        }
    }

    func onNetworkSelected() -> (Network) -> () {
        {
            [weak self] network in
            guard let self = self else { return }
            self.network = network
            self.refresh()
        }
    }
}
