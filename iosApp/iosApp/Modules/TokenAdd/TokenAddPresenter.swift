// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenAddPresenterEvent {

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
        
        self.network = interactor.defaultNetwork
    }
}

extension DefaultTokenAddPresenter: TokenAddPresenter {

    func present() {
        
        refresh()
    }

    func handle(_ event: TokenAddPresenterEvent) {

        switch event {
            
        case .addToken:
            
            addTokenTapped = true
            refresh()
            
        case .dismiss:
            
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenAddPresenter {
    
    func refresh(
        firstResponder: TokenAddViewModel.TextFieldType? = nil
    ) {
        
        validateFields()
        view?.update(
            with: makeViewModel(firstResponder: firstResponder)
        )
        
        // TODO: Fetch other contractAddress details async
        // if contractAddress is a valid one for the selected network
    }
    
    func makeViewModel(
        customToken: String? = nil,
        name: String? = nil,
        symbol: String? = nil,
        hint: String? = nil,
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
            contractAddress: .init(
                item: .init(
                    name: Localized("tokenAdd.contractAddress.title"),
                    value: nil
                ),
                placeholder: Localized("tokenAdd.contractAddress.placeholder"),
                hint: contractAddressValidationError,
                tag: TokenAddViewModel.TextFieldType.contractAddress.rawValue,
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
                onScanAction: makeScanAction(),
                isFirstResponder: firstResponder == .contractAddress
            ),
            name: .init(
                item: .init(
                    name: Localized("tokenAdd.name.title"),
                    value: nil
                ),
                placeholder: Localized("tokenAdd.name.placeholder"),
                hint: nameValidationError,
                tag: TokenAddViewModel.TextFieldType.name.rawValue,
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
                onScanAction: nil,
                isFirstResponder: firstResponder == .name
            ),
            symbol: .init(
                item: .init(
                    name: Localized("tokenAdd.symbol.title"),
                    value: nil
                ),
                placeholder: Localized("tokenAdd.symbol.placeholder"),
                hint: symbolValidationError,
                tag: TokenAddViewModel.TextFieldType.symbol.rawValue,
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
                onScanAction: nil,
                isFirstResponder: firstResponder == .symbol
            ),
            decimals: .init(
                item: .init(
                    name: Localized("tokenAdd.decimals.title"),
                    value: nil
                ),
                placeholder: Localized("tokenAdd.decimals.placeholder"),
                hint: decimalsValidationError,
                tag: TokenAddViewModel.TextFieldType.decimals.rawValue,
                onTextChanged: onTextChangedAction,
                onReturnTapped: onReturnTappedAction,
                onScanAction: nil,
                isFirstResponder: firstResponder == .decimals
            )
        )
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
        
        guard addTokenTapped else { return }
        
        guard !interactor.isValid(address: contractAddress ?? "", forNetwork: network) else {
            
            contractAddressValidationError = nil
            return
        }
        
        contractAddressValidationError = Localized(
            "tokenAdd.validation.field.address.\(network.name.lowercased()).invalid"
        )
    }
        
    func validateName() {
        
        guard addTokenTapped else { return }
        
        guard name?.isEmpty ?? true else {
            
            nameValidationError = nil
            return
        }
        
        nameValidationError = Localized("tokenAdd.validation.field.required")
    }

    func validateSymbol() {
        
        guard addTokenTapped else { return }
        
        guard symbol?.isEmpty ?? true else {
            
            symbolValidationError = nil
            return
        }
        
        symbolValidationError = Localized("tokenAdd.validation.field.required")

    }

    func validateDecimals() {
        
        guard addTokenTapped else { return }
        
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
    
    func makeScanAction() -> (TokenAddViewModel.TextFieldType) -> Void {
        
        {
            [weak self] textFieldType in
            
            guard let self = self else { return }
            
            switch textFieldType {
                
            case .contractAddress:
                
                self.wireframe.navigate(
                    to: .qrCodeScan(
                        network: self.network,
                        onCompletion: self.makeOnQRScanned()
                    )
                )
                
            default:
                break
            }
        }
    }
    
    func makeOnQRScanned() -> (String) -> Void {
        
        {
            [weak self] address in
            guard let self = self else { return }
            self.contractAddress = address
            self.refresh()
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
