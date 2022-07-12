// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenSendPresenterEvent {

    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case tokenChanged(to: Double)
    case feeChanged(to: String)
    case qrCodeScan
    case feeTapped
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
    private var fee: Web3NetworkFee = .low
    
    private var items = [TokenSendViewModel.Item]()
    private var fees = [Web3NetworkFee]()

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
                        tokenSymbolIcon: interactor.tokenIcon(for: context.web3Token),
                        tokenSymbol: context.web3Token.symbol.uppercased(),
                        tokenMaxAmount: context.web3Token.balance,
                        tokenMaxDecimals: context.web3Token.decimals,
                        currencyTokenPrice: context.web3Token.usdPrice,
                        shouldUpdateTextFields: false
                    )
                ),
                .send(
                    .init(
                        estimatedFee: makeEstimatedFee(),
                        feeType: makeFeeType(),
                        buttonState: .ready
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
            updateAddress(with: interactor.addressFormattedShort(
                address: clipboard,
                network: context.web3Token.network)
            )
            
        case let .tokenChanged(amount):
            
            updateToken(with: amount, shouldUpdateTextFields: false)
            
        case let .feeChanged(identifier):
            
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            updateToken(with: amount ?? 0, shouldUpdateTextFields: false)
            
        case .feeTapped:
            
            view?.presentFeePicker(
                with: makeFees()
            )
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
                        tokenSymbolIcon: interactor.tokenIcon(for: context.web3Token),
                        tokenSymbol: context.web3Token.symbol.uppercased(),
                        tokenMaxAmount: context.web3Token.balance,
                        tokenMaxDecimals: context.web3Token.decimals,
                        currencyTokenPrice: context.web3Token.usdPrice,
                        shouldUpdateTextFields: shouldUpdateTextFields
                    )
                ),
                .send(
                    .init(
                        estimatedFee: makeEstimatedFee(),
                        feeType: makeFeeType(),
                        buttonState: insufficientFunds ? .insufficientFunds : .ready
                    )
                )
            ]
        )
    }
    
    func makeEstimatedFee() -> String {
        
        let amountInUSD = interactor.networkFeeInUSD(network: context.web3Token.network, fee: fee)
        let timeInSeconds = interactor.networkFeeInSeconds(network: context.web3Token.network, fee: fee)
        
        let min: Double = Double(timeInSeconds) / Double(60)
        if min > 1 {
            return "\(amountInUSD.formatCurrency() ?? "") ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatCurrency() ?? "") ~ \(timeInSeconds) \(Localized("sec"))"
        }
    }
    
    func makeFees() -> [TokenSendViewModel.Fee] {
        
        let fees = interactor.networkFees(network: context.web3Token.network)
        self.fees = fees
        return fees.compactMap { [weak self] in
            guard let self = self else { return nil }
            return .init(
                id: $0.rawValue,
                name: $0.name,
                value: self.interactor.networkFeeInNetworkToken(
                    network: context.web3Token.network,
                    fee: $0
                )
            )
        }
    }
    
    func makeFeeType() -> TokenSendViewModel.Send.FeeType {
        
        switch fee {
            
        case .low:
            return .low
            
        case .medium:
            return .medium
            
        case .high:
            return .high
        }
    }
}

private extension Web3NetworkFee {
    
    var name: String {
        
        switch self {
        case .low:
            return Localized("tokenSend.cell.send.fee.low")
        case .medium:
            return Localized("tokenSend.cell.send.fee.medium")
        case .high:
            return Localized("tokenSend.cell.send.fee.high")
        }
    }
}
