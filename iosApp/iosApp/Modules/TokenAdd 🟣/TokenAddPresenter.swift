// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

// MARK: - TokenAddPresenterEvent

enum TokenAddPresenterEvent {
    case selectNetwork
    case addressChanged(to: String)
    case qrCodeScan
    case pasteAddress
    case inputChanged(for: TokenAddViewModel.TextFieldType, to: String)
    case returnKeyTapped(for: TokenAddViewModel.TextFieldType)
    case addToken
    case dismiss
}

// MARK: - TokenAddPresenter

protocol TokenAddPresenter {
    func present()
    func handle(_ event: TokenAddPresenterEvent)
}

// MARK: - DefaultTokenAddPresenter

final class DefaultTokenAddPresenter {

    private weak var view: TokenAddView?
    private let wireframe: TokenAddWireframe
    private let interactor: TokenAddInteractor
    private let context: TokenAddWireframeContext
    
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
        view: TokenAddView,
        wireframe: TokenAddWireframe,
        interactor: TokenAddInteractor,
        context: TokenAddWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
        
        self.network = context.network
    }
}

extension DefaultTokenAddPresenter: TokenAddPresenter {

    func present() {
        refresh()
    }

    func handle(_ event: TokenAddPresenterEvent) {
        switch event {
        case .selectNetwork:
            wireframe.navigate(to: .selectNetwork(onCompletion: onNetworkSelected()))
        case let .addressChanged(address):
            handleAddressChanged(to: address)
        case .qrCodeScan:
            handleQRCodeScan()
        case .pasteAddress:
            handlePasteAddress()
        case let .inputChanged(type, value):
            inputChanged(for: type, to: value)
        case let .returnKeyTapped(type):
            returnKeyTapped(for: type)
        case .addToken:
            handleAddToken()
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

// MARK: - Handlers

private extension DefaultTokenAddPresenter {
    
    func handleAddressChanged(to address: String) {
        if
            let formattedAddress = formattedAddress,
            address.hasPrefix(formattedAddress),
            address.count == (formattedAddress.count + 1)
        {
            refresh()
        } else if formattedAddress == address {
            refresh()
        } else if
            let formattedAddress = formattedAddress,
            formattedAddress.hasPrefix(address),
            address.count == (formattedAddress.count - 1)
        {
            contractAddress?.removeLast()
            refresh()
        } else {
            contractAddress = address
            refresh()
        }
    }
    
    func handleQRCodeScan() {
        view?.dismissKeyboard()
        wireframe.navigate(
            to: .qrCodeScan(
                network: network,
                onCompletion: onQRScanned()
            )
        )
    }
    
    func handlePasteAddress() {
        let clipboard = UIPasteboard.general.string ?? ""
        let isValid = network.isValid(address: clipboard)
        guard isValid else { return }
        contractAddress = clipboard
        refresh(
            firstResponder: nextFirstResponder()
        )
    }
    
    func handleAddToken() {
        addTokenTapped = true
        validateFields()
        if areAllFieldsValid() {
            interactor.addToken(
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

private extension DefaultTokenAddPresenter {
    
    func refresh(
        firstResponder: TokenAddViewModel.TextFieldType? = nil
    ) {
        validateFields()
        view?.update(with: viewModel(firstResponder: firstResponder))
        // TODO: Fetch other contractAddress details async
        // if contractAddress is a valid one for the selected network
    }
    
    func viewModel(
        firstResponder: TokenAddViewModel.TextFieldType?
    ) -> TokenAddViewModel {
        .init(
            title: Localized("tokenAdd.title"),
            network: .init(
                item: .init(
                    name: Localized("tokenAdd.network.title"),
                    value: network.name
                )
            ),
            address: .init(
                value: formattedAddress ?? contractAddress,
                isValid: false,
                becomeFirstResponder: firstResponder == .contractAddress
            ),
            name: .init(
                item: .init(
                    name: Localized("tokenAdd.name.title"),
                    value: name
                ),
                placeholder: Localized("tokenAdd.name.placeholder"),
                hint: addTokenTapped ? nameValidationError : nil,
                tag: TokenAddViewModel.TextFieldType.name.rawValue,
                isFirstResponder: firstResponder == .name
            ),
            symbol: .init(
                item: .init(
                    name: Localized("tokenAdd.symbol.title"),
                    value: symbol
                ),
                placeholder: Localized("tokenAdd.symbol.placeholder"),
                hint: addTokenTapped ? symbolValidationError : nil,
                tag: TokenAddViewModel.TextFieldType.symbol.rawValue,
                isFirstResponder: firstResponder == .symbol
            ),
            decimals: .init(
                item: .init(
                    name: Localized("tokenAdd.decimals.title"),
                    value: decimals
                ),
                placeholder: Localized("tokenAdd.decimals.placeholder"),
                hint: addTokenTapped ? decimalsValidationError : nil,
                tag: TokenAddViewModel.TextFieldType.decimals.rawValue,
                isFirstResponder: firstResponder == .decimals
            ),
            saveButtonTitle: saveButtonTitle(),
            saveButtonEnabled: saveButtonTitle() == Localized("tokenAdd.cta.valid")
        )
    }
    
    var formattedAddress: String? {
        guard let address = contractAddress else { return nil }
        guard network.isValid(address: address) else { return nil }
        return network.formatAddressShort(address)
    }
    
    func saveButtonTitle() -> String {
        let validTitle = Localized("tokenAdd.cta.valid")
        guard addTokenTapped else { return validTitle }
        guard contractAddressValidationError == nil else {
            return Localized("tokenAdd.cta.invalid.address")
        }
        guard areAllFieldsValid() else {
            return Localized("tokenAdd.cta.invalid")
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
    
    func inputChanged(for type: TokenAddViewModel.TextFieldType, to value: String) {
        switch type {
        case .contractAddress:
            contractAddress = value
        case .name:
            name = value
        case .symbol:
            symbol = value
        case .decimals:
            decimals = value
        }
        refresh()
    }
    
    func returnKeyTapped(for type: TokenAddViewModel.TextFieldType) {
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
        guard !network.isValid(address: contractAddress ?? "") else {
            contractAddressValidationError = nil
            return
        }
        contractAddressValidationError = Localized(
            "tokenAdd.validation.field.address.\(network.name.lowercased()).invalid"
        )
    }
        
    func validateName() {
        guard name?.isEmpty ?? true else {
            nameValidationError = nil
            return
        }
        nameValidationError = Localized("tokenAdd.validation.field.required")
    }

    func validateSymbol() {
        guard symbol?.isEmpty ?? true else {
            symbolValidationError = nil
            return
        }
        symbolValidationError = Localized("tokenAdd.validation.field.required")
    }

    func validateDecimals() {
        guard !(decimals?.isEmpty ?? true) else {
            decimalsValidationError = Localized("tokenAdd.validation.field.required")
            return
        }
        guard let intValue = try? decimals?.int() else {
            decimalsValidationError = Localized("tokenAdd.validation.field.decimal.int")
            return
        }
        guard 0 <= intValue, intValue <= 32 else {
            decimalsValidationError = Localized("tokenAdd.validation.field.decimal.range")
            return
        }
        decimalsValidationError = nil
    }
    
    func onQRScanned() -> (String) -> Void {
        {
            [weak self] address in
            guard let self = self else { return }
            self.contractAddress = address
            self.refresh(
                firstResponder: self.nextFirstResponder()
            )
        }
    }
    
    func nextFirstResponder() -> TokenAddViewModel.TextFieldType? {
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
