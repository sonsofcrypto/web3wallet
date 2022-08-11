// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum TokenSwapPresenterEvent {

    case limitSwapTapped
    case dismiss
    case tokenFromTapped
    case tokenFromChanged(to: BigInt)
    case tokenToTapped
    case tokenToChanged(to: BigInt)
    case swapFlip
    case providerTapped
    case slippageTapped
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
    
    private var tokenFrom: Web3Token!
    private var amountFrom: BigInt?
    private var tokenTo: Web3Token!
    private var amountTo: BigInt?

    private var fee: Web3NetworkFee = .low
    
    private var calculatingSwap = false

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
        
        let insufficientFunds = (amountFrom ?? .zero) > tokenFrom.balance || tokenFrom.balance == .zero
        
        return updateView(
            with: [
                .swap(
                    .init(
                        tokenFrom: .init(
                            tokenAmount: nil,
                            tokenSymbolIconName: interactor.tokenIconName(for: tokenFrom),
                            tokenSymbol: tokenFrom.symbol.uppercased(),
                            tokenMaxAmount: tokenFrom.balance,
                            tokenMaxDecimals: tokenFrom.decimals,
                            currencyTokenPrice: tokenFrom.usdPrice,
                            shouldUpdateTextFields: false,
                            shouldBecomeFirstResponder: true,
                            networkName: tokenFrom.network.name
                        ),
                        tokenTo: .init(
                            tokenAmount: nil,
                            tokenSymbolIconName: interactor.tokenIconName(for: tokenTo),
                            tokenSymbol: tokenTo.symbol.uppercased(),
                            tokenMaxAmount: tokenTo.balance,
                            tokenMaxDecimals: tokenTo.decimals,
                            currencyTokenPrice: tokenTo.usdPrice,
                            shouldUpdateTextFields: false,
                            shouldBecomeFirstResponder: false,
                            networkName: tokenTo.network.name
                        ),
                        tokenSwapProviderViewModel: makeTokenSwapProviderViewModel(),
                        tokenSwapPriceViewModel: makeTokenPriceViewModel(),
                        tokenSwapSlippageViewModel: makeTokenSwapSlippageViewModel(),
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: makeEstimatedFee(),
                            feeType: makeFeeType()
                        ),
                        buttonState: insufficientFunds
                        ? .insufficientFunds(providerIconName: makeSelectedProviderIconName())
                        : .swap(providerIconName: makeSelectedProviderIconName())
                    )
                )//,
                //.limit
            ]
        )
    }

    func handle(_ event: TokenSwapPresenterEvent) {

        switch event {
            
        case .limitSwapTapped:
            
            wireframe.navigate(to: .underConstructionAlert)
        case .dismiss:
            
            wireframe.dismiss()
            
        case .tokenFromTapped:
            
            wireframe.navigate(
                to: .selectMyToken(
                    selectedToken: tokenFrom,
                    onCompletion: makeOnTokenFromSelected()
                )
            )
        
        case let .tokenFromChanged(amount):
            
            updateSwap(amountFrom: amount, shouldUpdateTextFields: false)
            
        case .tokenToTapped:
            
            wireframe.navigate(
                to: .selectToken(
                    selectedToken: tokenTo,
                    onCompletion: makeOnTokenToSelected()
                )
            )
            
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
            
        case .providerTapped:
            
            wireframe.navigate(to: .underConstructionAlert)
            
        case .slippageTapped:
            
            wireframe.navigate(to: .underConstructionAlert)
            
        case let .feeChanged(identifier):
            
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            refreshView(with: .init(amountFrom: amountFrom, amountTo: amountTo))
            
        case .feeTapped:
            
            view?.presentFeePicker(
                with: makeFees()
            )
            
        case .review:
            
            guard (amountFrom ?? .zero) > .zero else {
                
                refreshView(
                    with: .init(amountFrom: nil, amountTo: nil),
                    shouldUpdateFromTextField: true,
                    shouldUpdateToTextField: true,
                    shouldFromBecomeFirstResponder: true
                )
                return
            }
            
            guard tokenFrom.balance >= (amountFrom ?? .zero) else { return }
            
            guard !calculatingSwap else { return }
            
            wireframe.navigate(
                to: .confirmSwap(
                    dataIn: .init(
                        tokenFrom: makeConfirmationSwapTokenFrom(),
                        tokenTo: makeConfirmationSwapTokenTo(),
                        provider: makeConfirmationProvider(),
                        estimatedFee: makeConfirmationSwapEstimatedFee()
                    )
                )
            )
        }
    }
    
    func makeConfirmationSwapEstimatedFee() -> Web3NetworkFee {
        
        switch fee {
            
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
    
    func makeConfirmationSwapTokenFrom() -> ConfirmationWireframeContext.SwapContext.Token {
        
        .init(
            iconName: interactor.tokenIconName(for: tokenFrom),
            token: tokenFrom,
            value: amountFrom ?? .zero
        )
    }
    
    func makeConfirmationSwapTokenTo() -> ConfirmationWireframeContext.SwapContext.Token {
        
        .init(
            iconName: interactor.tokenIconName(for: tokenTo),
            token: tokenTo,
            value: amountTo ?? .zero
        )
    }
    
    func makeConfirmationProvider() -> ConfirmationWireframeContext.SwapContext.Provider {
        
        .init(
            iconName: makeSelectedProviderIconName(),
            name: selectedProviderName,
            slippage: selectedSlippage
        )
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
        amountFrom: BigInt,
        shouldUpdateTextFields: Bool
    ) {
        
        self.amountFrom = amountFrom
        
        let swapDataIn = SwapDataIn(
            type: .calculateAmountTo(amountFrom: amountFrom),
            tokenFrom: tokenFrom,
            tokenTo: tokenTo
        )
        
        calculatingSwap = true
        
        interactor.swapTokenAmount(dataIn: swapDataIn) { [weak self] swapDataOut in
            
            guard let self = self else { return }
            self.calculatingSwap = false
            self.refreshView(with: swapDataOut, shouldUpdateToTextField: true)
        }
    }
    
    func updateSwap(
        amountTo: BigInt,
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
        
        let insufficientFunds = (amountFrom ?? .zero) > tokenFrom.balance || tokenFrom.balance == .zero
        
        updateView(
            with: [
                .swap(
                    .init(
                        tokenFrom: .init(
                            tokenAmount: amountFrom,
                            tokenSymbolIconName: interactor.tokenIconName(for: tokenFrom),
                            tokenSymbol: tokenFrom.symbol.uppercased(),
                            tokenMaxAmount: tokenFrom.balance,
                            tokenMaxDecimals: tokenFrom.decimals,
                            currencyTokenPrice: tokenFrom.usdPrice,
                            shouldUpdateTextFields: shouldUpdateFromTextField,
                            shouldBecomeFirstResponder: shouldFromBecomeFirstResponder,
                            networkName: tokenFrom.network.name
                        ),
                        tokenTo: .init(
                            tokenAmount: amountTo,
                            tokenSymbolIconName: interactor.tokenIconName(for: tokenTo),
                            tokenSymbol: tokenTo.symbol.uppercased(),
                            tokenMaxAmount: tokenTo.balance,
                            tokenMaxDecimals: tokenTo.decimals,
                            currencyTokenPrice: tokenTo.usdPrice,
                            shouldUpdateTextFields: shouldUpdateToTextField,
                            shouldBecomeFirstResponder: false,
                            networkName: tokenTo.network.name
                        ),
                        tokenSwapProviderViewModel: makeTokenSwapProviderViewModel(),
                        tokenSwapPriceViewModel: makeTokenPriceViewModel(),
                        tokenSwapSlippageViewModel: makeTokenSwapSlippageViewModel(),
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: makeEstimatedFee(),
                            feeType: makeFeeType()
                        ),
                        buttonState: insufficientFunds
                        ? .insufficientFunds(
                            providerIconName: makeSelectedProviderIconName()
                        )
                        : .swap(
                            providerIconName: makeSelectedProviderIconName()
                        )
                    )
                )//,
//                .limit
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
            iconName: makeSelectedProviderIconName(),
            name: selectedProviderName
        )
    }
    
    func makeTokenSwapSlippageViewModel() -> TokenSwapSlippageViewModel {
        
        .init(value: selectedSlippage)
    }
    
    func makeTokenPriceViewModel() -> TokenSwapPriceViewModel {
        
        let value = "0.588392859"
        return .init(value: "1 \(tokenFrom.symbol) ≈ \(value) \(tokenTo.symbol)")
    }
    
    func makeSelectedProviderIconName() -> String {
        
        "\(selectedProviderName)-provider"
    }
    
    var selectedProviderName: String {
        "uniswap"
    }
    
    var selectedSlippage: String {
        
        "1%"
    }
    
    func makeOnTokenFromSelected() -> (Web3Token) -> Void {
        
        {
            [weak self] token in
            guard let self = self else { return }
            self.tokenFrom = token
            self.refreshView(with: .init(amountFrom: .zero, amountTo: .zero))
        }
    }
    
    func makeOnTokenToSelected() -> (Web3Token) -> Void {
        
        {
            [weak self] token in
            guard let self = self else { return }
            self.tokenTo = token
            self.updateSwap(amountFrom: self.amountFrom ?? .zero, shouldUpdateTextFields: false)
        }
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
