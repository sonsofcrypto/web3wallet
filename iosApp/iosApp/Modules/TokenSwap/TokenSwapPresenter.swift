// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenSwapPresenterEvent {

    case dismiss
    case tokenChanged(to: Double)
    case feeChanged(to: String)
    case feeTapped
}

protocol TokenSwapPresenter: AnyObject {

    func present()
    func handle(_ event: TokenSwapPresenterEvent)
}

final class DefaultTokenSwapPresenter {

    private weak var view: TokenSwapView?
    private let interactor: TokenSwapInteractor
    private let wireframe: TokenSwapWireframe
    private let context: TokenSwapWireframeContext
    
    private var address: String?
    private var amount: Double?
    private var fee: Web3NetworkFee = .low
    
    private var items = [TokenSwapViewModel.Item]()
    private var fees = [Web3NetworkFee]()

    init(
        view: TokenSwapView,
        interactor: TokenSwapInteractor,
        wireframe: TokenSwapWireframe,
        context: TokenSwapWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultTokenSwapPresenter: TokenSwapPresenter {

    func present() {
        
        updateView(
            with: [
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

    func handle(_ event: TokenSwapPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.dismiss()
            
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

private extension DefaultTokenSwapPresenter {
    
    func updateView(with items: [TokenSwapViewModel.Item]) {
        
        view?.update(
            with: .init(
                title: Localized("TokenSwap.title"),
                items: items
            )
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
    
    func makeFees() -> [FeesPickerViewModel] {
        
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
    
    func makeFeeType() -> TokenSwapViewModel.Send.FeeType {
        
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
            return Localized("TokenSwap.cell.send.fee.low")
        case .medium:
            return Localized("TokenSwap.cell.send.fee.medium")
        case .high:
            return Localized("TokenSwap.cell.send.fee.high")
        }
    }
}
