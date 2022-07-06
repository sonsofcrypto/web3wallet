// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenSendPresenterEvent {

    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case tokenChanged(to: Double)
    case qrCodeScan
}

protocol TokenSendPresenter: AnyObject {

    func present()
    func handle(_ event: TokenSendPresenterEvent)
}

final class DefaultTokenSendPresenter {

    private weak var view: TokenSendView?
    private let interactor: TokenSendInteractor
    private let wireframe: TokenSendWireframe
    private let context: TokenSendWireframeContext
    
    private var address: String?
    private var amount: Double?
    private var items = [TokenSendViewModel.Item]()

    init(
        view: TokenSendView,
        interactor: TokenSendInteractor,
        wireframe: TokenSendWireframe,
        context: TokenSendWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultTokenSendPresenter: TokenSendPresenter {

    func present() {
        
        updateView(
            with: [
                .address(
                    .init(
                        value: nil,
                        isValid: false
                    )
                ),
                .token(
                    .init(
                        tokenAmount: nil,
                        tokenSymbol: context.web3Token.symbol.uppercased(),
                        tokenMaxAmount: context.web3Token.balance,
                        insufficientFunds: false,
                        shouldUpdateTextFields: false
                    )
                )
            ]
        )
    }

    func handle(_ event: TokenSendPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.dismiss()

        case .qrCodeScan:
            
            view?.dismissKeyboard()
            let onQRCodeScanned = makeOnQRCodeScanned()
            wireframe.navigate(to: .qrCodeScan(onCompletion: onQRCodeScanned))
            
        case let .addressChanged(address):
            
            updateAddress(with: address)
            
        case .pasteAddress:
            
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = interactor.isAddressValid(address: clipboard, network: context.web3Token.network)
            guard isValid else { return }
            updateAddress(with: clipboard)
            
        case let .tokenChanged(amount):
            
            updateToken(with: amount, shouldUpdateTextFields: false)
        }
    }
}

private extension DefaultTokenSendPresenter {
    
    func updateView(with items: [TokenSendViewModel.Item]) {
        
        view?.update(
            with: .init(
                title: Localized("tokenSend.title", arg: context.web3Token.symbol),
                items: items
            )
        )
    }
    
    func makeOnQRCodeScanned() -> (String) -> Void {
        
        { [weak self] address in
            
            guard let self = self else { return }
            self.updateAddress(with: address)
        }
    }
    
    func updateAddress(with address: String) {
        
        self.address = address
        
        let isValid = interactor.isAddressValid(address: address, network: context.web3Token.network)
        
        updateView(
            with: [
                .address(
                    .init(
                        value: address,
                        isValid: isValid
                    )
                )
            ]
        )
    }
    
    func updateToken(
        with amount: Double,
        shouldUpdateTextFields: Bool
    ) {
        
        self.amount = amount
        
        let insufficientFunds = amount > context.web3Token.balance
        
        updateView(
            with: [
                .token(
                    .init(
                        tokenAmount: amount,
                        tokenSymbol: context.web3Token.symbol.uppercased(),
                        tokenMaxAmount: context.web3Token.balance,
                        insufficientFunds: insufficientFunds,
                        shouldUpdateTextFields: shouldUpdateTextFields
                    )
                )
            ]
        )
    }
}
