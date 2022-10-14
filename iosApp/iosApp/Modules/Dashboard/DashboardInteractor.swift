// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum DashboardInteractorEvent {
    case didSelectKeyStoreItem
    case didSelectNetwork(network: Network?)
    case didChangeNetworks(networks: [Network])
    case didUpdateMarketdata(market: [String : CurrencyMarketData]?)
    case didUpdateCandles(network: Network, currency: Currency)
    case didUpdateBlock(network: Network, blockNumber: BigInt)
    case didUpdateBalance(network: Network, currency: Currency, balance: BigInt)
    case didUpdateNFTs
}

protocol DashboardInteractorLister: AnyObject {
    func handle(_ event: DashboardInteractorEvent)
}

protocol DashboardInteractor: AnyObject {
    var selectedNetwork: Network? { get }
    func enabledNetworks() -> [Network]
    func wallet(for network: Network) -> Wallet?
    func currencies(for network: Network) -> [Currency]
    func setCurrencies(_ currencies: [Currency], network: Network)
    func metadata(for currency: Currency) -> CurrencyMetadata?
    func marketdata(for currency: Currency) -> CurrencyMarketData?
    func candles(for currency: Currency) -> [Candle]?
    func cryptoBalance(for network: Network, currency: Currency) -> BigInt
    func fiatBalance(for network: Network, currency: Currency) -> Double
    func nfts(for network: Network) -> [NFTItem]
    func notifications() -> [Web3Notification]
    func totalFiatBalance() -> Double
    func reloadBalances()
    func reloadData()
    func addListener(_ listener: DashboardInteractorLister)
    func removeListener(_ listener: DashboardInteractorLister)
}

final class DefaultDashboardInteractor {
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let nftsService: NFTsService
    private var listeners: [WeakContainer] = []

    init(
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        nftsService: NFTsService
    ) {
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.nftsService = nftsService
        NotificationCenter.default.addObserver(
            self, selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        print("[DEBUG][Interactor] deinit \(String(describing: self))")
        NotificationCenter.default.removeObserver(self)
    }
}

extension DefaultDashboardInteractor: DashboardInteractor {
    
    var selectedNetwork: Network? { networksService.network }

    func enabledNetworks() -> [Network] {
        return networksService.enabledNetworks()
    }

    func wallet(for network: Network) -> Wallet? {
        networksService.wallet(network: network)
    }

    func currencies(for network: Network) -> [Currency] {
        walletService.currencies(network: network)
    }

    func setCurrencies(_ currencies: [Currency], network: Network) {
        walletService.setCurrencies(currencies: currencies, network: network)
    }

    func metadata(for currency: Currency) -> CurrencyMetadata? {
        currencyStoreService.metadata(currency: currency)
    }

    func marketdata(for currency: Currency) -> CurrencyMarketData? {
        currencyStoreService.marketData(currency: currency)
    }

    func candles(for currency: Currency) -> [Candle]? {
        currencyStoreService.candles(currency: currency)
    }

    func cryptoBalance(for network: Network, currency: Currency) -> BigInt {
        walletService.balance(network: network, currency: currency)
    }

    func fiatBalance(for network: Network, currency: Currency) -> Double {
        web3walletcore.Formatters.Companion.shared.crypto(
            amount: cryptoBalance(for: network, currency: currency),
            decimals: currency.decimals(),
            mul: marketdata(for: currency)?.currentPrice?.doubleValue ?? 0.0
        )
    }

    func nfts(for network: Network) -> [NFTItem] {
        nftsService.yourNFTs(forNetwork: network)
    }

    func notifications() -> [Web3Notification] {
        // TODO: Review this
        let web3ServiceLegacy: Web3ServiceLegacy = AppAssembler.resolve()
        return web3ServiceLegacy.dashboardNotifications
    }

    func totalFiatBalance() -> Double {
        var total = 0.0
        walletService.networks().forEach { network in
            walletService.currencies(network: network).forEach { currency in
                total += fiatBalance(for: network, currency: currency)
            }
        }
        return total
    }

    func reloadBalances() {
        walletService.reloadAllBalances()
    }

    func reloadData() {
        let allCurrencies = walletService.networks()
            .map { walletService.currencies(network: $0) }
            .reduce([Currency](), { $0 + $1 })

        if allCurrencies.isEmpty {
            return
        }
        currencyStoreService.fetchMarketData(
            currencies: allCurrencies,
            completionHandler: { [weak self] (market, _) in
                DispatchQueue.main.async {
                    self?.emit(.didUpdateMarketdata(market: market))
                }
            }
        )
        reloadCandles()
        nftsService.fetchNFTs { [weak self] _ in
            DispatchQueue.main.async { self?.emit(.didUpdateNFTs) }
        }
    }

    func reloadCandles() {
        for network in walletService.networks() {
            for currency in walletService.currencies(network: network) {
                currencyStoreService.fetchCandles(currency: currency) { [weak self] _,_ in
                    self?.emit(
                        .didUpdateCandles(network: network, currency: currency)
                    )
                }
            }
        }
    }

    @objc func didEnterBackground() {
        walletService.pausePolling()
    }

    @objc func willEnterForeground() {
        walletService.startPolling()
    }
    
    func addListener(_ listener: DashboardInteractorLister) {
        listeners = [WeakContainer(listener)]
        networksService.add(listener__: self)
        walletService.add(listener_: self)
    }

    func removeListener(_ listener: DashboardInteractorLister) {
        listeners = []
        networksService.remove(listener__: self)
        walletService.remove(listener_: self)
    }
}

// MARK: - Listeners

extension DefaultDashboardInteractor: NetworksListener, WalletListener {

    private func emit(_ event: DashboardInteractorEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event_ event: NetworksEvent) {
        // print("=== NetworksEvent ", event)
        if let _ = event as? NetworksEvent.NetworkDidChange {
            reloadData()
        }
        emit(event.toInteractorEvent())
    }

    func handle(event__: WalletEvent) {
        // print("=== WalletEvent ", event__)
        if let event = event__.toInteractorEvent() {
            emit(event)
        }
    }

    private class WeakContainer {
        weak var value: DashboardInteractorLister?
        init(_ value: DashboardInteractorLister) {
            self.value = value
        }
    }
}

// MARK: - NetworksEvent

extension NetworksEvent {

    func toInteractorEvent() -> DashboardInteractorEvent {
        if let _ = self as? NetworksEvent.KeyStoreItemDidChange {
            return .didSelectKeyStoreItem
        }
        if let event = self as? NetworksEvent.NetworkDidChange {
            return .didSelectNetwork(network: event.network)
        }
        if let event = self as? NetworksEvent.EnabledNetworksDidChange {
            return .didChangeNetworks(networks: event.networks)
        }
        fatalError("Unhandled event \(self)")
    }
}

extension WalletEvent {

    func toInteractorEvent() -> DashboardInteractorEvent? {
        if let event = self as? WalletEvent.Balance {
            return .didUpdateBalance(
                network: event.network,
                currency: event.currency,
                balance: event.balance
            )
        }
        if let event = self as? WalletEvent.BlockNumber {
            return .didUpdateBlock(
                network: event.network,
                blockNumber: event.number
            )
        }

        return nil
    }
}
