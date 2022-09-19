// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum TokenSwapPresenterEvent {
    case limitSwapTapped
    case dismiss
    case currencyFromTapped
    case currencyFromChanged(to: BigInt)
    case currencyToTapped
    case currencyToChanged(to: BigInt)
    case swapFlip
    case providerTapped
    case slippageTapped
    case feeChanged(to: String)
    case feeTapped
    case approve
    case review
}

protocol TokenSwapPresenter: AnyObject {
    func present()
    func handle(_ event: TokenSwapPresenterEvent)
}

final class DefaultTokenSwapPresenter {
    private weak var view: TokenSwapView?
    private let wireframe: TokenSwapWireframe
    private let interactor: TokenSwapInteractor
    private let context: TokenSwapWireframeContext
    
    private var items = [TokenSwapViewModel.Item]()
    private var fees = [Web3NetworkFee]()
    private var currencyFrom: Currency!
    private var amountFrom: BigInt?
    private var currencyTo: Currency!
    private var amountTo: BigInt?
    private var invalidQuote: Bool = false
    private var fee: Web3NetworkFee = .low
    private let priceImpactWarningThreashold = 0.1
    
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
        interactor.addListener(self)
        loadCurrencies()
    }
    
    deinit {
        print("[DEBUG][Presenter] deinit \(String(describing: self))")
        interactor.removeListener(self)
    }
}

extension DefaultTokenSwapPresenter: TokenSwapPresenter {

    func present() {
        updateView(
            with: [
                .swap(
                    .init(
                        currencyFrom: .init(
                            tokenAmount: nil,
                            tokenSymbolIconName: currencyFrom.iconName,
                            tokenSymbol: currencyFrom.symbol.uppercased(),
                            tokenMaxAmount: currencyFromBalance,
                            tokenMaxDecimals: currencyFrom.decimalsUInt,
                            currencyTokenPrice: currencyFrom.fiatPrice,
                            shouldUpdateTextFields: false,
                            shouldBecomeFirstResponder: false,
                            networkName: context.network.name
                        ),
                        currencyTo: .init(
                            tokenAmount: nil,
                            tokenSymbolIconName: currencyTo.iconName,
                            tokenSymbol: currencyTo.symbol.uppercased(),
                            tokenMaxAmount: currencyToBalance,
                            tokenMaxDecimals: currencyTo.decimalsUInt,
                            currencyTokenPrice: currencyTo.fiatPrice,
                            shouldUpdateTextFields: false,
                            shouldBecomeFirstResponder: false,
                            networkName: context.network.name,
                            tokenInputEnabled: false
                        ),
                        currencySwapProviderViewModel: currencySwapProviderViewModel(),
                        currencySwapPriceViewModel: currencyPriceViewModel(),
                        currencySwapSlippageViewModel: currencySwapSlippageViewModel(),
                        currencyNetworkFeeViewModel: .init(
                            estimatedFee: makeEstimatedFee(),
                            feeType: feeType()
                        ),
                        isCalculating: isCalculating,
                        providerAsset: selectedProviderIconName(),
                        approveState: makeApproveState(),
                        buttonState: makeButtonState()
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
        case .currencyFromTapped:
            wireframe.navigate(to: .selectCurrencyFrom(onCompletion: onCurrencyFromSelected()))
        case let .currencyFromChanged(amount):
            refreshView()
            getQuote(for: amount)
        case .currencyToTapped:
            wireframe.navigate(to: .selectCurrencyFrom(onCompletion: onCurrencyToSelected()))
        case .currencyToChanged: break
        case .swapFlip:
            amountFrom = .zero
            amountTo = .zero
            invalidQuote = true
            let currentCurrencyFrom = currencyFrom
            let currentCurrencyTo = currencyTo
            currencyFrom = currentCurrencyTo
            currencyTo = currentCurrencyFrom
            getQuote(for: amountFrom ?? .zero)
            refreshView(shouldUpdateFromTextField: true)
        case .providerTapped:
            wireframe.navigate(to: .underConstructionAlert)
        case .slippageTapped:
            wireframe.navigate(to: .underConstructionAlert)
        case let .feeChanged(identifier):
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            refreshView()
        case .feeTapped:
            view?.presentFeePicker(with: _fees())
        case .approve:
            wireframe.navigate(
                to: .confirmApproval(
                    currency: currencyTo,
                    onApproved: { [weak self] (password, salt) in
                        guard let self = self else { return }
                        self.interactor.approveSwap(
                            network: self.context.network,
                            currency: self.currencyTo,
                            password: password,
                            salt: salt
                        )
                    }
                )
            )
        case .review:
            guard (amountFrom ?? .zero) > .zero else {
                refreshView(
                    shouldUpdateFromTextField: true,
                    shouldFromBecomeFirstResponder: true
                )
                return
            }
            guard currencyFromBalance >= (amountFrom ?? .zero) else { return }
            switch interactor.swapState {
            case .swap:
                wireframe.navigate(
                    to: .confirmSwap(
                        data: .init(
                            network: context.network,
                            provider: confirmationProvider(),
                            amountFrom: amountFrom ?? .zero,
                            amountTo: amountTo ?? .zero,
                            currencyFrom: currencyFrom,
                            currencyTo: currencyTo,
                            estimatedFee: confirmationSwapEstimatedFee(),
                            swapService: interactor.swapService
                        )
                    )
                )
            default: break
            }
        }
    }
    
    func confirmationSwapEstimatedFee() -> Web3NetworkFee {
        switch fee {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        }
    }
    
    func confirmationProvider() -> ConfirmationWireframeContext.SwapContext.Provider {
        .init(
            iconName: selectedProviderIconName(),
            name: selectedProviderName,
            slippage: selectedSlippage
        )
    }
}

private extension DefaultTokenSwapPresenter {
    
    var currencyFromBalance: BigInt {
        interactor.balance(currency: currencyFrom, network: context.network)
    }
    
    var currencyToBalance: BigInt {
        interactor.balance(currency: currencyTo, network: context.network)
    }
    
    func loadCurrencies() {
        currencyFrom = context.currencyFrom ?? interactor.defaultCurrencyFrom(for: context.network)
        currencyTo = context.currencyTo ?? interactor.defaultCurrencyTo(for: context.network)
    }
    
    func updateView(with items: [TokenSwapViewModel.Item]) {
        
        view?.update(
            with: .init(
                title: Localized("tokenSwap.title"),
                items: items
            )
        )
    }
        
    func getQuote(for amountFrom: BigInt) {
        self.amountFrom = amountFrom
        interactor.getQuote(data: data)
    }
    
    var data: SwapData {
        .init(
            inputCurrency: currencyFrom,
            outputCurrency: currencyTo,
            inputAmount: amountFrom ?? .zero
        )

    }
    
    func refreshView(
        shouldUpdateFromTextField: Bool = false,
        shouldFromBecomeFirstResponder: Bool = false
    ) {
        if !invalidQuote { amountTo = interactor.outputAmount }
        updateView(
            with: [
                .swap(
                    .init(
                        currencyFrom: .init(
                            tokenAmount: amountFrom,
                            tokenSymbolIconName: currencyFrom.iconName,
                            tokenSymbol: currencyFrom.symbol.uppercased(),
                            tokenMaxAmount: currencyFromBalance,
                            tokenMaxDecimals: currencyFrom.decimalsUInt,
                            currencyTokenPrice: currencyFrom.fiatPrice,
                            shouldUpdateTextFields: shouldUpdateFromTextField,
                            shouldBecomeFirstResponder: shouldFromBecomeFirstResponder,
                            networkName: context.network.name
                        ),
                        currencyTo: .init(
                            tokenAmount: amountTo,
                            tokenSymbolIconName: currencyTo.iconName,
                            tokenSymbol: currencyTo.symbol.uppercased(),
                            tokenMaxAmount: currencyToBalance,
                            tokenMaxDecimals: currencyTo.decimalsUInt,
                            currencyTokenPrice: currencyTo.fiatPrice,
                            shouldUpdateTextFields: true,
                            shouldBecomeFirstResponder: false,
                            networkName: context.network.name,
                            tokenInputEnabled: false
                        ),
                        currencySwapProviderViewModel: currencySwapProviderViewModel(),
                        currencySwapPriceViewModel: currencyPriceViewModel(),
                        currencySwapSlippageViewModel: currencySwapSlippageViewModel(),
                        currencyNetworkFeeViewModel: .init(
                            estimatedFee: makeEstimatedFee(),
                            feeType: feeType()
                        ),
                        isCalculating: isCalculating,
                        providerAsset: selectedProviderIconName(),
                        approveState: makeApproveState(),
                        buttonState: makeButtonState()
                    )
                )//,
//                .limit
            ]
        )
    }
    
    var isCalculating: Bool {
        interactor.outputAmountState == .loading && amountFrom != nil && amountFrom != .zero
    }
    
    func makeApproveState() -> TokenSwapViewModel.Swap.ApproveState {
        guard amounFromtGreaterThanZero && !insufficientFunds else {
            // NOTE: This simply hides the Approve button since we won't be able to swap
            // anyway
            return .approved
        }
        guard !isCalculating else {
            // NOTE: Here is we are still calculating a quote we don't want to show the approve
            // button yet in case that we need to, we will do once the quote is retrieved
            return .approved
        }
        guard interactor.swapState != .notAvailable else {
            // NOTE: Here is we know that there is no pool available to do the swap, we do not
            // show approved since you would not be able to swap anyway
            return .approved
        }
        switch interactor.approvingState {
        case .approve:
            return .approve
        case .approving:
            return .approving
        case .approved:
            return .approved
        }
    }
    
    func makeButtonState() -> TokenSwapViewModel.Swap.ButtonState {
        guard amounFromtGreaterThanZero else {
            return .invalid(text: Localized("tokenSwap.cell.button.state.enterAmount"))
        }
        guard !insufficientFunds else {
            return .invalid(
                text: Localized(
                    "tokenSwap.cell.button.state.insufficientBalance",
                    arg: currencyFrom.symbol
                )
            )
        }
        if isCalculating { return .loading }
        switch interactor.swapState {
        case .notAvailable:
            return .invalid(text: Localized("tokenSwap.cell.button.state.noPoolsFound"))
        case .swap:
            return priceImpact >= priceImpactWarningThreashold ? .swapAnyway(
                text: Localized("tokenSwap.cell.button.state.swapAnyway", arg: (priceImpact * 100).toString())
            ) : .swap
        }
    }
    
    var amounFromtGreaterThanZero: Bool {
        amountFrom != nil && amountFrom != .zero
    }
    
    var insufficientFunds: Bool {
        (amountFrom ?? .zero) > currencyFromBalance || currencyFromBalance == .zero
    }
    
    func makeEstimatedFee() -> String {
        
        let amountInUSD = interactor.networkFeeInUSD(network: context.network, fee: fee)
        let timeInSeconds = interactor.networkFeeInSeconds(network: context.network, fee: fee)
        
        let min: Double = Double(timeInSeconds) / Double(60)
        if min > 1 {
            return "\(amountInUSD.formatStringCurrency()) ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatStringCurrency()) ~ \(timeInSeconds) \(Localized("sec"))"
        }
    }
    
    func _fees() -> [FeesPickerViewModel] {
        let fees = interactor.networkFees(network: context.network)
        self.fees = fees
        return fees.compactMap { [weak self] in
            guard let self = self else { return nil }
            return .init(
                id: $0.rawValue,
                name: $0.name,
                value: self.interactor.networkFeeInNetworkToken(
                    network: context.network,
                    fee: $0
                )
            )
        }
    }
    
    func feeType() -> TokenNetworkFeeViewModel.FeeType {
        switch fee {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        }
    }
    
    func currencySwapProviderViewModel() -> TokenSwapProviderViewModel {
        .init(
            iconName: selectedProviderIconName(),
            name: selectedProviderName
        )
    }
    
    func currencySwapSlippageViewModel() -> TokenSwapSlippageViewModel {
        .init(value: selectedSlippage)
    }
    
    func currencyPriceViewModel() -> TokenSwapPriceViewModel {
        
        guard currencyFrom.fiatPrice != 0, currencyTo.fiatPrice != 0 else {
            return .init(value: "1 \(currencyFrom.symbol) ≈ ? \(currencyTo.symbol)")
        }
        guard let fromAmount = try? BigInt.Companion().from(
            string: "1".appending(decimals: currencyFrom.decimalsUInt),
            base: 10
        ) else {
            return .init(value: "1 \(currencyFrom.symbol) ≈ ? \(currencyTo.symbol)")
        }
        let currencyFromAmountBigDec = fromAmount.toBigDec(decimals: currencyFrom.decimalsUInt)
        let currencyFromFiatBigDec = currencyFrom.fiatPrice.bigDec
        let currencyToFiatBigDec = currencyTo.fiatPrice.bigDec
        let amountToDecimals = BigDec.Companion().from(
            string: "1".appending(decimals: currencyTo.decimalsUInt),
            base: 10
        )
        let amountTo = currencyFromAmountBigDec.mul(
            value: currencyFromFiatBigDec
        ).div(
            value: currencyToFiatBigDec
        ).mul( // this is to add the decimals for the token we convert to
            value: amountToDecimals
        )
        
        var value = amountTo.toBigInt().formatString(
            type: .long(minDecimals: 10),
            decimals: currencyTo.decimalsUInt
        )
        if value.nonDecimals.count > 10 {
            value = amountTo.toBigInt().formatString(
                type: .long(minDecimals: 4),
                decimals: currencyTo.decimalsUInt
            )
        } else if value.nonDecimals.count > 6 {
            value = amountTo.toBigInt().formatString(
                type: .long(minDecimals: 5),
                decimals: currencyTo.decimalsUInt
            )
        } else if value.nonDecimals.count > 3 {
            value = amountTo.toBigInt().formatString(
                type: .long(minDecimals: 7),
                decimals: currencyTo.decimalsUInt
            )
        }
        return .init(value: "1 \(currencyFrom.symbol) ≈ \(value) \(currencyTo.symbol)")
    }
    
    func selectedProviderIconName() -> String { "\(selectedProviderName)-provider" }
    
    var selectedProviderName: String { "uniswap" }
    
    var selectedSlippage: String { "1%"}
    
    func onCurrencyFromSelected() -> (Currency) -> Void {
        {
            [weak self] currency in
            guard let self = self else { return }
            self.currencyFrom = currency
            self.amountFrom = .zero
            self.amountTo = .zero
            self.invalidQuote = true
            self.getQuote(for: .zero)
            self.refreshView(shouldUpdateFromTextField: true, shouldFromBecomeFirstResponder: true)
        }
    }
    
    func onCurrencyToSelected() -> (Currency) -> Void {
        {
            [weak self] currency in
            guard let self = self else { return }
            self.currencyTo = currency
            self.getQuote(for: self.amountFrom ?? .zero)
        }
    }
    
    var priceImpact: Double {
        guard
            let currencyFrom = currencyFrom,
            let currencyTo = currencyTo,
            let amountFrom = amountFrom,
            let amountTo = amountTo
        else {
            return 0.0
        }
            
        return PriceImpactCalculator().calculate(
            currencyFrom: currencyFrom,
            currencyTo: currencyTo,
            fromAmount: amountFrom,
            toAmount: amountTo
        )
    }
}

private extension Web3NetworkFee {
    var name: String {
        switch self {
        case .low: return Localized("low")
        case .medium: return Localized("medium")
        case .high: return Localized("high")
        }
    }
}

extension DefaultTokenSwapPresenter: SwapInteractorLister {
    
    func handle(swapEvent event: UniswapEvent) {
        guard interactor.isCurrentQuote(data: data) else {
            print("[SWAP][QUOTE] - quote not valid, ignoring event")
            return
        }
        print("[SWAP][QUOTE] - quote valid, refreshing UI")
        invalidQuote = false
        refreshView()
    }
}

private struct PriceImpactCalculator {
    func calculate(
        currencyFrom: Currency,
        currencyTo: Currency,
        fromAmount: BigInt,
        toAmount: BigInt
    ) -> Double {
        let fromFiatValue = currencyFrom.fiatValue(for: fromAmount)
        let toFiatValue = currencyTo.fiatValue(for: toAmount)
        return 1 - (toFiatValue/fromFiatValue)
    }
}
