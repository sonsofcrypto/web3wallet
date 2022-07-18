// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenSwapPresenterEvent {

    case dismiss
    case tokenFromChanged(to: Double)
    case tokenToChanged(to: Double)
    case swapFlip
    case feeChanged(to: String)
    case feeTapped
    case review
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
    
    private var items = [TokenSwapViewModel.Item]()
    private var fees = [Web3NetworkFee]()
    
    private var amountFrom: Double?
    private var tokenFrom: Web3Token!
    private var amountTo: Double?
    private var tokenTo: Web3Token!

    private var fee: Web3NetworkFee = .low

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
        
        loadTokens()
    }
}

extension DefaultTokenSwapPresenter: TokenSwapPresenter {

    func present() {
        
        updateView(
            with: [
                .swap(
                    .init(
                        tokenFrom: .init(
                            tokenAmount: nil,
                            tokenSymbolIcon: interactor.tokenIcon(for: tokenFrom),
                            tokenSymbol: tokenFrom.symbol.uppercased(),
                            tokenMaxAmount: tokenFrom.balance,
                            tokenMaxDecimals: tokenFrom.decimals,
                            currencyTokenPrice: tokenFrom.usdPrice,
                            shouldUpdateTextFields: false,
                            shouldBecomeFirstResponder: true
                        ),
                        tokenTo: .init(
                            tokenAmount: nil,
                            tokenSymbolIcon: interactor.tokenIcon(for: tokenTo),
                            tokenSymbol: tokenTo.symbol.uppercased(),
                            tokenMaxAmount: tokenTo.balance,
                            tokenMaxDecimals: tokenTo.decimals,
                            currencyTokenPrice: tokenTo.usdPrice,
                            shouldUpdateTextFields: false,
                            shouldBecomeFirstResponder: false
                        ),
                        tokenSwapProviderViewModel: makeTokenSwapProviderViewModel(),
                        tokenSwapPriceViewModel: makeTokenPriceViewModel(),
                        tokenSwapSlippageViewModel: makeTokenSwapSlippageViewModel(),
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: makeEstimatedFee(),
                            feeType: makeFeeType()
                        ),
                        buttonState: .swap(providerIcon: makeSelectedProviderIcon())
                    )
                )
            ]
        )
    }

    func handle(_ event: TokenSwapPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.dismiss()
        
        case let .tokenFromChanged(amount):
            
            updateSwap(amountFrom: amount, shouldUpdateTextFields: false)
            
        case let .tokenToChanged(amount):
            
            updateSwap(amountTo: amount, shouldUpdateTextFields: false)
            
        case .swapFlip:
            
            let currentAmountFrom = amountFrom
            let currentAmountTo = amountTo
            amountFrom = currentAmountTo
            amountTo = currentAmountFrom
            
            let currentTokenFrom = tokenFrom
            let currentTokenTo = tokenTo
            tokenFrom = currentTokenTo
            tokenTo = currentTokenFrom
            
            refreshView(
                with: .init(amountFrom: amountFrom, amountTo: amountTo),
                shouldUpdateFromTextField: true,
                shouldUpdateToTextField: true
            )
            
        case let .feeChanged(identifier):
            
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            refreshView(with: .init(amountFrom: amountFrom, amountTo: amountTo))
            
        case .feeTapped:
            
            view?.presentFeePicker(
                with: makeFees()
            )
            
        case .review:
            
            guard (amountFrom ?? 0) > 0 else {
                
                refreshView(
                    with: .init(amountFrom: nil, amountTo: nil),
                    shouldUpdateFromTextField: true,
                    shouldUpdateToTextField: true,
                    shouldFromBecomeFirstResponder: true
                )
                return
            }
            
            
        }
    }
}

private extension DefaultTokenSwapPresenter {
    
    func loadTokens() {
        
        tokenFrom = context.tokenFrom ?? interactor.defaultTokenFrom()
        tokenTo = context.tokenTo ?? interactor.defaultTokenTo()
    }
    
    func updateView(with items: [TokenSwapViewModel.Item]) {
        
        view?.update(
            with: .init(
                title: Localized("tokenSwap.title"),
                items: items
            )
        )
    }
        
    func updateSwap(
        amountFrom: Double,
        shouldUpdateTextFields: Bool
    ) {
        
        self.amountFrom = amountFrom
        
        let swapDataIn = SwapDataIn(
            type: .calculateAmountTo(amountFrom: amountFrom),
            tokenFrom: tokenFrom,
            tokenTo: tokenTo
        )
        
        interactor.swapTokenAmount(dataIn: swapDataIn) { [weak self] swapDataOut in
            
            guard let self = self else { return }
            self.refreshView(with: swapDataOut, shouldUpdateToTextField: true)
        }
    }
    
    func updateSwap(
        amountTo: Double,
        shouldUpdateTextFields: Bool
    ) {
        
        self.amountTo = amountTo
        
        let swapDataIn = SwapDataIn(
            type: .calculateAmountFrom(amountTo: amountTo),
            tokenFrom: tokenFrom,
            tokenTo: tokenTo
        )
        
        interactor.swapTokenAmount(dataIn: swapDataIn) { [weak self] swapDataOut in
            
            guard let self = self else { return }
            self.refreshView(with: swapDataOut, shouldUpdateFromTextField: true)
        }
    }
    
    func refreshView(
        with swapDataOut: SwapDataOut,
        shouldUpdateFromTextField: Bool = false,
        shouldUpdateToTextField: Bool = false,
        shouldFromBecomeFirstResponder: Bool = false
    ) {
        
        amountFrom = swapDataOut.amountFrom
        amountTo = swapDataOut.amountTo
        
        let insufficientFunds = (amountFrom ?? 0) > tokenFrom.balance
        
        self.updateView(
            with: [
                .swap(
                    .init(
                        tokenFrom: .init(
                            tokenAmount: amountFrom,
                            tokenSymbolIcon: interactor.tokenIcon(for: tokenFrom),
                            tokenSymbol: tokenFrom.symbol.uppercased(),
                            tokenMaxAmount: tokenFrom.balance,
                            tokenMaxDecimals: tokenFrom.decimals,
                            currencyTokenPrice: tokenFrom.usdPrice,
                            shouldUpdateTextFields: shouldUpdateFromTextField,
                            shouldBecomeFirstResponder: shouldFromBecomeFirstResponder
                        ),
                        tokenTo: .init(
                            tokenAmount: amountTo,
                            tokenSymbolIcon: interactor.tokenIcon(for: tokenTo),
                            tokenSymbol: tokenTo.symbol.uppercased(),
                            tokenMaxAmount: tokenTo.balance,
                            tokenMaxDecimals: tokenTo.decimals,
                            currencyTokenPrice: tokenTo.usdPrice,
                            shouldUpdateTextFields: shouldUpdateToTextField,
                            shouldBecomeFirstResponder: false
                        ),
                        tokenSwapProviderViewModel: makeTokenSwapProviderViewModel(),
                        tokenSwapPriceViewModel: makeTokenPriceViewModel(),
                        tokenSwapSlippageViewModel: makeTokenSwapSlippageViewModel(),
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: self.makeEstimatedFee(),
                            feeType: self.makeFeeType()
                        ),
                        buttonState: insufficientFunds ? .insufficientFunds : .swap(
                            providerIcon: self.makeSelectedProviderIcon()
                        )
                    )
                )
            ]
        )
    }
    
    func makeEstimatedFee() -> String {
        
        let amountInUSD = interactor.networkFeeInUSD(network: tokenFrom.network, fee: fee)
        let timeInSeconds = interactor.networkFeeInSeconds(network: tokenFrom.network, fee: fee)
        
        let min: Double = Double(timeInSeconds) / Double(60)
        if min > 1 {
            return "\(amountInUSD.formatCurrency() ?? "") ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatCurrency() ?? "") ~ \(timeInSeconds) \(Localized("sec"))"
        }
    }
    
    func makeFees() -> [FeesPickerViewModel] {
        
        let fees = interactor.networkFees(network: tokenFrom.network)
        self.fees = fees
        return fees.compactMap { [weak self] in
            guard let self = self else { return nil }
            return .init(
                id: $0.rawValue,
                name: $0.name,
                value: self.interactor.networkFeeInNetworkToken(
                    network: tokenFrom.network,
                    fee: $0
                )
            )
        }
    }
    
    func makeFeeType() -> TokenNetworkFeeViewModel.FeeType {
        
        switch fee {
            
        case .low:
            return .low
            
        case .medium:
            return .medium
            
        case .high:
            return .high
        }
    }
    
    func makeTokenSwapProviderViewModel() -> TokenSwapProviderViewModel {
        
        .init(
            icon: makeSelectedProviderIcon(),
            name: selectedProviderName
        )
    }
    
    func makeTokenSwapSlippageViewModel() -> TokenSwapSlippageViewModel {
        
        .init(value: "1%")
    }
    
    func makeTokenPriceViewModel() -> TokenSwapPriceViewModel {
        
        let value = "0.588392859"
        return .init(value: "1 \(tokenFrom.symbol) ≈ \(value) \(tokenTo.symbol)")
    }
    
    func makeSelectedProviderIcon() -> Data {
        
        UIImage(named: "provider-\(selectedProviderName)")!.pngData()!
    }
    
    var selectedProviderName: String {
        "1inch"
    }
}

private extension Web3NetworkFee {
    
    var name: String {
        
        switch self {
        case .low:
            return Localized("low")
        case .medium:
            return Localized("medium")
        case .high:
            return Localized("high")
        }
    }
}
