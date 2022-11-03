// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct SwapData {
    let inputCurrency: Currency
    let outputCurrency: Currency
    let inputAmount: BigInt
}

protocol CurrencyInteractorLister: AnyObject {
    func handle(swapEvent event: UniswapEvent)
}

enum CurrencySwapInteractorOutputAmountState {
    case loading
    case ready
}

enum CurrencySwapInteractorApprovalState {
    case approve
    case approving
    case approved
}

enum CurrencySwapInteractorSwapState {
    case noPools
    case notAvailable
    case swap
}

protocol CurrencySwapInteractor: AnyObject {
    var outputAmount: BigInt { get }
    var outputAmountState: CurrencySwapInteractorOutputAmountState { get }
    var approvingState: CurrencySwapInteractorApprovalState { get }
    var swapState: CurrencySwapInteractorSwapState { get }
    var swapService: UniswapService { get }
    func defaultCurrencyFrom(for network: Network) -> Currency
    func defaultCurrencyTo(for network: Network) -> Currency
    func networkFees(network: Network) -> [NetworkFee]
    func getQuote(data: SwapData)
    func isCurrentQuote(data: SwapData) -> Bool
    func addListener(_ listener: CurrencyInteractorLister)
    func removeListener(_ listener: CurrencyInteractorLister)
    func approveSwap(
        network: Network,
        currency: Currency,
        password: String,
        salt: String
    )
    func balance(currency: Currency, network: Network) -> BigInt
    func fiatPrice(currency: Currency) -> Double
}

final class DefaultCurrencySwapInteractor {
    private let network: Network
    private let walletService: WalletService
    private let networksService: NetworksService
    let swapService: UniswapService
    private let currencyStoreService: CurrencyStoreService
    
    private var listener: WeakContainer?
    
    init(
        network: Network,
        walletService: WalletService,
        networksService: NetworksService,
        swapService: UniswapService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.network = network
        self.walletService = walletService
        self.networksService = networksService
        self.swapService = swapService
        self.currencyStoreService = currencyStoreService
        configureUniswapService()
    }
    
    deinit {
        print("[DEBUG][Interactor] deinit \(String(describing: self))")
    }
}

extension DefaultCurrencySwapInteractor: CurrencySwapInteractor {

    var outputAmount: BigInt { swapService.outputAmount }
    
    var outputAmountState: CurrencySwapInteractorOutputAmountState {
        switch swapService.outputState {
        case is OutputState.Loading: return .loading
        default: break
        }
        switch swapService.poolsState {
        case is PoolsState.Loading: return .loading
        default: break
        }
        return .ready
    }
    
    var approvingState: CurrencySwapInteractorApprovalState {
        switch swapService.approvalState {
        case is ApprovalState.NeedsApproval: return .approve
        case is ApprovalState.Approving: return .approving
        default: return .approved
        }
    }
    
    var swapState: CurrencySwapInteractorSwapState {
        guard !(swapService.poolsState is PoolsState.NoPoolsFound) else { return .noPools }
        switch swapService.outputState {
        case is OutputState.Unavailable: return .notAvailable
        default: return .swap
        }
    }
    
    func defaultCurrencyFrom(for network: Network) -> Currency {
        walletService.currencies(network: network)[safe: 0] ?? network.nativeCurrency
    }
    func defaultCurrencyTo(for network: Network) -> Currency {
        walletService.currencies(network: network)[safe: 1] ?? network.nativeCurrency
    }
    
    func networkFees(network: Network) -> [NetworkFee] {
        networksService.networkFees(network: network)
    }

    func getQuote(data: SwapData) {
        swapService.inputAmount = data.inputAmount
        swapService.inputCurrency = data.inputCurrency
        swapService.outputCurrency = data.outputCurrency
        let input = data.inputAmount.toDecimalString()
        let inputC = data.inputCurrency.symbol
        let outputC = data.outputCurrency.symbol
        print("[SWAP][QUOTE][REQUEST] - Swap: \(input) '\(inputC)' to '\(outputC)'")
    }
    
    func isCurrentQuote(data: SwapData) -> Bool {
        guard swapService.inputAmount == data.inputAmount else { return false }
        guard swapService.inputCurrency.symbol == data.inputCurrency.symbol else { return false }
        guard swapService.outputCurrency.symbol == data.outputCurrency.symbol else { return false }
        return true
    }

    
    func approveSwap(
        network: Network,
        currency: Currency,
        password: String,
        salt: String
    ) {
        // TODO: Review scenarios where this can fail or return without triggering requestApproval
        guard let wallet = networksService.wallet(network: network) else { return }
        do {
            try wallet.unlock(password: password, salt: salt)
            swapService.requestApproval(
                currency: currency,
                wallet: wallet,
                completionHandler: { _ in }
            )
        } catch {
            // do nothing
        }
    }
    
    func balance(currency: Currency, network: Network) -> BigInt {
        walletService.balance(network: network, currency: currency)
    }
    
    func fiatPrice(currency: Currency) -> Double {
        currencyStoreService.marketData(currency: currency)?.currentPrice?.doubleValue ?? 0
    }
}

private extension DefaultCurrencySwapInteractor {
    
    func configureUniswapService() {
        guard let wallet = networksService.wallet(network: network) else {
            fatalError("Unable to configure Uniswap service, no wallet found.")
        }
        let provider = networksService.provider(network: network)
        swapService.wallet = wallet
        swapService.provider = provider
    }
}

extension DefaultCurrencySwapInteractor: UniswapListener {
    
    func addListener(_ listener: CurrencyInteractorLister) {
        self.listener = WeakContainer(listener)
        swapService.add(listener___: self)
    }
    
    func removeListener(_ listener: CurrencyInteractorLister) {
        self.listener = nil
        swapService.remove(listener___: self)
    }
    
    func handle(event___ event: UniswapEvent) {
        print("[SWAP][EVENT] - \(event)")
        emit(event)
    }

    private func emit(_ event: UniswapEvent) {
        listener?.value?.handle(swapEvent: event)
    }

    private class WeakContainer {
        weak var value: CurrencyInteractorLister?

        init(_ value: CurrencyInteractorLister) {
            self.value = value
        }
    }
}
