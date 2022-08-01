// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenAddPresenterEvent {

    case addressChanged(to: String)
    case qrCodeScan
    case pasteAddress
    case addToken
    case dismiss
}

protocol TokenAddPresenter {

    func present()
    func handle(_ event: TokenAddPresenterEvent)
}

final class DefaultTokenAddPresenter {

    private weak var view: TokenAddView?
    private let interactor: TokenAddInteractor
    private let wireframe: TokenAddWireframe
    private let context: TokenAddWireframeContext
    
    private var network: Web3Network!
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
        interactor: TokenAddInteractor,
        wireframe: TokenAddWireframe,
        context: TokenAddWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
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
            
        case let .addressChanged(address):
            
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
            
        case .qrCodeScan:
            
            view?.dismissKeyboard()
            
            wireframe.navigate(
                to: .qrCodeScan(
                    network: network,
                    onCompletion: makeOnQRScanned()
                )
            )

        case .pasteAddress:
            
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = interactor.isValid(address: clipboard, forNetwork: network)
            guard isValid else { return }
            contractAddress = clipboard
            refresh(
                firstResponder: makeNextFirstResponder()
            )
            
        case .addToken:
            
            addTokenTapped = true
            
            validateFields()
            
            if areAllFieldsValid() {
                
                interactor.addToken(
                    .init(
                        address: contractAddress ?? "",
                        name: name ?? "",
                        symbol: symbol ?? "",
                        decimals: Int(decimals ?? "0") ?? 0
                    )
                ) { [weak self] in
                    
                    guard let self = self else { return }
                    self.view?.dismissKeyboard()
                    self.wireframe.dismiss()
                }
            } else {
                
                refresh()
            }
            
        case .dismiss:
            
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenAddPresenter {
    
    func makeNextFirstResponder() -> TokenAddViewModel.TextFieldType? {
        
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
    
    var formattedAddress: String? {
        
        guard let address = contractAddress else { return nil }
        
        guard interactor.isValid(address: address, forNetwork: network) else { return nil }
        
        return interactor.addressFormattedShort(
            address: address,
            network: network
        )
    }
    
    func refresh(
        firstResponder: TokenAddViewModel.TextFieldType? = nil
    ) {
        
        validateFields()
        
        let viewModel = makeViewModel(
            firstResponder: firstResponder
        )
        view?.update(with: viewModel)
        
        // TODO: Fetch other contractAddress details async
        // if contractAddress is a valid one for the selected network
    }
    
    func makeViewModel(
        firstResponder: TokenAddViewModel.TextFieldType?
    ) -> TokenAddViewModel {
        
        let onTextChangedAction = makeOnTextChangedAction()
        let onReturnTappedAction = makeOnReturnTappedAction()
        
        return .init(
            title: Localized("tokenAdd.title"),
            network: .init(
                item: .init(
                    name: Localized("tokenAdd.network.title"),
                    value: network.name
                ),
                onTapped: makeNetworkOnTapped()
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
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
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
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
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
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
                isFirstResponder: firstResponder == .decimals
            ),
            saveButtonTitle: makeSaveButtonTitle()
        )
    }
    
    func makeSaveButtonTitle() -> String {
        
        let validTitle = Localized("tokenAdd.cta.valid")
        
        guard addTokenTapped else {
            
            return validTitle
        }
        
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
        else {
            
            return false
        }
        
        return true
    }
    
    func makeOnTextChangedAction() -> ((TokenAddViewModel.TextFieldType, String) -> Void) {
        
        {
            [weak self] (textFieldType, value) in
            
            guard let self = self else { return }
            
            switch textFieldType {
                
            case .contractAddress:
                self.contractAddress = value

            case .name:
                self.name = value

            case .symbol:
                self.symbol = value

            case .decimals:
                self.decimals = value
            }
            
            self.refresh()
        }
    }
    
    func makeOnReturnTappedAction() -> ((TokenAddViewModel.TextFieldType) -> Void) {
        
        {
            [weak self] textFieldType in
            
            guard let self = self else { return }
            
            switch textFieldType {
                
            case .contractAddress:
                self.refresh(firstResponder: .name)

            case .name:
                self.refresh(firstResponder: .symbol)

            case .symbol:
                self.refresh(firstResponder: .decimals)

            case .decimals:
                self.refresh(firstResponder: .contractAddress)
            }
        }
    }

    func validateFields() {
        
        validateContractAddress()
        validateName()
        validateSymbol()
        validateDecimals()
    }

    func validateContractAddress() {
        
        guard !interactor.isValid(address: contractAddress ?? "", forNetwork: network) else {
            
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
    
    func makeOnQRScanned() -> (String) -> Void {
        
        {
            [weak self] address in
            guard let self = self else { return }
            self.contractAddress = address
            self.refresh(
                firstResponder: self.makeNextFirstResponder()
            )
        }
    }

    func makeNetworkOnTapped() -> (() -> Void) {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.wireframe.navigate(to: .selectNetwork(onCompletion: self.onNetworkSelected()))
        }
    }
    
    func onNetworkSelected() -> (Web3Network) -> () {
        
        {
            [weak self] network in
            guard let self = self else { return }
            self.network = network
            self.refresh()
        }
    }
}
