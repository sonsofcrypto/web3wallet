// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum CurrencySwapPresenterEvent {
    case limitSwapTapped
    case dismiss
    case currencyFromTapped
    case currencyFromChanged(to: BigInt)
    case currencyToTapped
    case currencyToChanged(to: BigInt)
    case swapFlip
    case providerTapped
    case slippageTapped
    case feeChanged(to: NetworkFee)
    case feeTapped
    case approve
    case review
}

protocol CurrencySwapPresenter: AnyObject {
    func present()
    func handle(_ event: CurrencySwapPresenterEvent)
}

final class DefaultCurrencySwapPresenter {
    private weak var view: CurrencySwapView?
    private let wireframe: CurrencySwapWireframe
    private let interactor: CurrencySwapInteractor
    private let context: CurrencySwapWireframeContext
    
    private var items = [CurrencySwapViewModel.Item]()
    private var fees = [NetworkFee]()
    private var currencyFrom: Currency!
    private var amountFrom: BigInt?
    private var currencyTo: Currency!
    private var amountTo: BigInt?
    private var invalidQuote: Bool = false
    private var fee: NetworkFee?
    private let priceImpactWarningThreashold = 0.1
    
    init(
        view: CurrencySwapView,
        interactor: CurrencySwapInteractor,
        wireframe: CurrencySwapWireframe,
        context: CurrencySwapWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
        interactor.addListener(self)
        loadCurrencies()
        refreshFees()
    }
    
    deinit {
        print("[DEBUG][Presenter] deinit \(String(describing: self))")
        interactor.removeListener(self)
    }
}

extension DefaultCurrencySwapPresenter: CurrencySwapPresenter {

    func present() {
        updateView(
            with: [
                .swap(
                    .init(
                        currencyFrom: .init(
                            amount: nil,
                            symbolIconName: currencyFrom.iconName,
                            symbol: currencyFrom.symbol.uppercased(),
                            maxAmount: currencyFromBalance,
                            maxDecimals: currencyFrom.decimalsUInt.uInt32,
                            fiatPrice: currencyFrom.fiatPrice,
                            updateTextField: false,
                            becomeFirstResponder: false,
                            networkName: context.network.name,
                            inputEnabled: true
                        ),
                        currencyTo: .init(
                            amount: nil,
                            symbolIconName: currencyTo.iconName,
                            symbol: currencyTo.symbol.uppercased(),
                            maxAmount: currencyToBalance,
                            maxDecimals: currencyTo.decimalsUInt.uInt32,
                            fiatPrice: currencyTo.fiatPrice,
                            updateTextField: false,
                            becomeFirstResponder: false,
                            networkName: context.network.name,
                            inputEnabled: false
                        ),
                        currencySwapProviderViewModel: currencySwapProviderViewModel(),
                        currencySwapPriceViewModel: currencyPriceViewModel(),
                        currencySwapSlippageViewModel: currencySwapSlippageViewModel(),
                        currencyNetworkFeeViewModel: fee?.toNetworkFeeViewModel(
                            currencyFiatPrice: interactor.fiatPrice(currency: context.network.nativeCurrency),
                            amountDigits: UInt32(10),
                            fiatPriceDigits: UInt32(8),
                            fiatPriceCurrencyCode: "usd"
                        ) ?? emptyNetworkFeeViewModel(),
                        isCalculating: isCalculating,
                        providerAsset: selectedProviderIconName(),
                        approveState: approveState(),
                        buttonState: buttonState()
                    )
                )//,
                //.limit
            ]
        )
    }

    func handle(_ event: CurrencySwapPresenterEvent) {
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
        case let .feeChanged(fee):
            self.fee = fee
            refreshView()
        case .feeTapped:
            view?.presentFeePicker(with: fees)
        case .approve:
            guard approveState() == .approve, let fee = fee else { return }
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
                    },
                    networkFee: fee
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
            guard currencyFromBalance >= (amountFrom ?? .zero), let fee = fee else { return }
            switch interactor.swapState {
            case .swap:
                let context = ConfirmationWireframeContext.Swap(
                    data: .init(
                        network: context.network,
                        provider: confirmationProvider(),
                        amountFrom: amountFrom ?? .zero,
                        amountTo: amountTo ?? .zero,
                        currencyFrom: currencyFrom,
                        currencyTo: currencyTo,
                        networkFee: fee,
                        swapService: interactor.swapService
                    )
                )
                wireframe.navigate(to: .confirmSwap(context: context))
            default: break
            }
        }
    }
    
    func confirmationProvider() -> ConfirmationWireframeContext.SwapContextProvider {
        .init(
            iconName: selectedProviderIconName(),
            name: selectedProviderName,
            slippage: selectedSlippage
        )
    }
}

private extension DefaultCurrencySwapPresenter {
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
    
    func updateView(with items: [CurrencySwapViewModel.Item]) {
        view?.update(
            with: .init(
                title: Localized("currencySwap.title"),
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
                            amount: amountFrom,
                            symbolIconName: currencyFrom.iconName,
                            symbol: currencyFrom.symbol.uppercased(),
                            maxAmount: currencyFromBalance,
                            maxDecimals: currencyFrom.decimalsUInt.uInt32,
                            fiatPrice: currencyFrom.fiatPrice,
                            updateTextField: shouldUpdateFromTextField,
                            becomeFirstResponder: shouldFromBecomeFirstResponder,
                            networkName: context.network.name,
                            inputEnabled: true
                        ),
                        currencyTo: .init(
                            amount: amountTo,
                            symbolIconName: currencyTo.iconName,
                            symbol: currencyTo.symbol.uppercased(),
                            maxAmount: currencyToBalance,
                            maxDecimals: currencyTo.decimalsUInt.uInt32,
                            fiatPrice: currencyTo.fiatPrice,
                            updateTextField: true,
                            becomeFirstResponder: false,
                            networkName: context.network.name,
                            inputEnabled: false
                        ),
                        currencySwapProviderViewModel: currencySwapProviderViewModel(),
                        currencySwapPriceViewModel: currencyPriceViewModel(),
                        currencySwapSlippageViewModel: currencySwapSlippageViewModel(),
                        currencyNetworkFeeViewModel: fee?.toNetworkFeeViewModel(
                            currencyFiatPrice: interactor.fiatPrice(currency: context.network.nativeCurrency),
                            amountDigits: UInt32(10),
                            fiatPriceDigits: UInt32(8),
                            fiatPriceCurrencyCode: "usd"
                        ) ?? emptyNetworkFeeViewModel(),
                        isCalculating: isCalculating,
                        providerAsset: selectedProviderIconName(),
                        approveState: approveState(),
                        buttonState: buttonState()
                    )
                )//,
//                .limit
            ]
        )
    }
    
    func emptyNetworkFeeViewModel() -> NetworkFeeViewModel {
        .init(name: Localized("networkFeeView.estimatedFee"), amount: [], time: [], fiat: [])
    }
    
    var isCalculating: Bool {
        interactor.outputAmountState == .loading && amountFrom != nil && amountFrom != .zero
    }
    
    func approveState() -> CurrencySwapViewModel.Swap.ApproveState {
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
        case .approve: return .approve
        case .approving: return .approving
        case .approved: return .approved
        }
    }
    
    func buttonState() -> CurrencySwapViewModel.Swap.ButtonState {
        guard amounFromtGreaterThanZero else {
            return .invalid(text: Localized("currencySwap.cell.button.state.enterAmount"))
        }
        guard !insufficientFunds else {
            return .invalid(
                text: Localized(
                    "currencySwap.cell.button.state.insufficientBalance",
                    currencyFrom.symbol.uppercased()
                )
            )
        }
        if isCalculating { return .loading }
        switch interactor.swapState {
        case .noPools, .notAvailable:
            return .invalid(text: Localized("currencySwap.cell.button.state.noPoolsFound"))
        case .swap:
            return priceImpact >= priceImpactWarningThreashold ? .swapAnyway(
                text: Localized("currencySwap.cell.button.state.swapAnyway", (priceImpact * 100).toString())
            ) : .swap
        }
    }
    
    var amounFromtGreaterThanZero: Bool {
        amountFrom != nil && amountFrom != .zero
    }
    
    var insufficientFunds: Bool {
        (amountFrom ?? .zero) > currencyFromBalance || currencyFromBalance == .zero
    }
    
    func refreshFees() {
        fees = interactor.networkFees(network: context.network)
        guard fee == nil, !fees.isEmpty else { return }
        fee = fees[0]
    }
    
    func estimatedFee() -> [Formatters.Output] {
        guard let fee = fee else { return [Formatters.OutputNormal(value: "-")] }
        var outputFormat = Formatters.Companion.shared.currency.format(
            amount: fee.amount, currency: fee.currency, style: Formatters.StyleCustom(maxLength: 10)
        )
        let min: Double = Double(fee.seconds) / Double(60)
        var value = ""
        if min > 1 {
            value = " ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            value = " ~ \(fee.seconds) \(Localized("sec"))"
        }
        outputFormat.append(
            Formatters.OutputNormal(value: value)
        )
        return outputFormat
    }
    
    func feeName() -> String {
        guard let fee = fee else { return "-" }
        return fee.name
    }
    
    func currencySwapProviderViewModel() -> CurrencySwapProviderViewModel {
        .init(
            iconName: selectedProviderIconName(),
            name: selectedProviderName
        )
    }
    
    func currencySwapSlippageViewModel() -> CurrencySwapSlippageViewModel {
        .init(value: selectedSlippage)
    }
    
    func currencyPriceViewModel() -> CurrencySwapPriceViewModel {
        let fromSymbol = currencyFrom.symbol.uppercased()
        let toSymbol = currencyTo.symbol.uppercased()
        guard currencyFrom.fiatPrice != 0, currencyTo.fiatPrice != 0 else {
            return .init(value: "1 \(fromSymbol) ≈ ? \(toSymbol)")
        }
        guard let fromAmount = try? BigInt.Companion().from(
            string: "1".appending(decimals: currencyFrom.decimalsUInt),
            base: 10
        ) else {
            return .init(value: "1 \(fromSymbol) ≈ ? \(toSymbol)")
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
        return .init(value: "1 \(fromSymbol) ≈ \(value) \(toSymbol)")
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

extension DefaultCurrencySwapPresenter: CurrencyInteractorLister {
    
    func handle(swapEvent event: UniswapEvent) {
        guard interactor.isCurrentQuote(data: data) else {
            print("[SWAP][QUOTE] - quote not valid, ignoring event")
            return
        }
        print("[SWAP][QUOTE] - quote valid, refreshing UI - outputAmount: \(interactor.outputAmount.toDecimalString())")
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
