// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum DashboardInteractorEvent {
    case didSelectKeyStoreItem
    case didSelectNetwork(network: Network?)
    case didChangeNetworks(networks: [Network])
    case didUpdateMarketInfo(market: [String : Market]?)
    case didUpdateCandles(network: Network, currency: Currency)
    case didUpdateBlock(blockNumber: BigInt)
    case didUpdateBalance(wallet: Wallet, currency: Currency, balance: BigInt)
    case didUpdateTransactionCount(wallet: Wallet, count: BigInt)
    case didUpdateNFTs
}

protocol DashboardInteractorLister: AnyObject {
    func handle(_ event: DashboardInteractorEvent)
}

protocol DashboardInteractor: AnyObject {
    var notifications: [Web3Notification] { get }
    var allNetworks: [Web3Network] { get }
    var myTokens: [Web3Token] { get }
    func tokenIcon(for token: Web3Token) -> Data
    func priceData(for token: Web3Token) -> [ Web3Candle ]

    func enabledNetworks() -> [Network]
    func wallet(for network: Network) -> Wallet?
    func currencies(for network: Network) -> [Currency]
    func setCurrencies(_ currencies: [Currency], network: Network)
    func metadata(for currency: Currency) -> Market?
    func candles(for currency: Currency) -> [Candle]?
    // TODO: Refactor to be url or image name
    func image(for currency: Currency) -> Data
    func colors(for currency: Currency) -> (String, String)
    func cryptoBalance(for wallet: Wallet?, currency: Currency) -> BigInt
    func fiatBalance(for wallet: Wallet?, currency: Currency) -> Double
    func fiatPrice(for wallet: Wallet?, currency: Currency) -> Double
    func totalFiatBalance() -> Double
    func nfts(for network: Web3Network) -> [NFTItem]
    func reloadData()

    func addListener(_ listener: DashboardInteractorLister)
    func removeListener(_ listener: DashboardInteractorLister?)
}

final class DefaultDashboardInteractor {

    private let networksService: NetworksService
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService
    private let walletsStateService: WalletsStateService
    private let web3ServiceLegacy: Web3ServiceLegacy
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService
    private var listeners: [WeakContainer] = []

    init(
        networksService: NetworksService,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService,
        walletsStateService: WalletsStateService,
        web3ServiceLegacy: Web3ServiceLegacy,
        priceHistoryService: PriceHistoryService,
        nftsService: NFTsService
    ) {
        self.web3ServiceLegacy = web3ServiceLegacy
        self.networksService = networksService
        self.currenciesService = currenciesService
        self.currencyMetadataService = currencyMetadataService
        self.walletsStateService = walletsStateService
        self.priceHistoryService = priceHistoryService
        self.nftsService = nftsService

        NotificationCenter.default.addObserver(
            self, selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(willEnterBackground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
}

extension DefaultDashboardInteractor: DashboardInteractor {

    var notifications: [Web3Notification] {
        web3ServiceLegacy.dashboardNotifications
    }

    var allNetworks: [Web3Network] {
        web3ServiceLegacy.allNetworks
    }

    var myTokens: [Web3Token] {
        return web3ServiceLegacy.myTokens
    }

    func tokenIcon(for token: Web3Token) -> Data {
        web3ServiceLegacy.tokenIcon(for: token)
    }

    func priceData(for token: Web3Token) -> [Web3Candle] {
        priceHistoryService.priceData(for: token, period: .lastXDays(43))
    }

    func nfts(for network: Web3Network) -> [NFTItem] {
        nftsService.yourNFTs(forNetwork: network)
    }
}

extension DefaultDashboardInteractor {

    func enabledNetworks() -> [Network] {
        networksService.enabledNetworks()
    }

    func wallet(for network: Network) -> Wallet? {
        networksService.wallet(network: network)
    }

    func currencies(for network: Network) -> [Currency] {
        guard let wallet = networksService.wallet(network: network) else {
            return []
        }

        return currenciesService.currencies(wallet: wallet)
    }


    func setCurrencies(_ currencies: [Currency], network: Network) {
        guard let wallet = networksService.wallet(network: network) else {
            return
        }

        currenciesService.setSelected(currencies: currencies, wallet: wallet)
    }

    func metadata(for currency: Currency) -> Market? {
        currencyMetadataService.market(currency: currency)
    }

    func candles(for currency: Currency) -> [Candle]? {
        currencyMetadataService.cachedCandles(currency: currency)
    }

    // TODO: Refactor to be url or image name
    func image(for currency: Currency) -> Data {
        var image: UIImage?

        if let id = currency.coinGeckoId {
            image = UIImage(named: id)
        }

        image = image ?? UIImage(named: "currency_placeholder")
        return image!.pngData()!
    }

    func colors(for currency: Currency) -> (String, String) {
        let colors = currencyMetadataService.colors(currency: currency)
        return (
            String(colors.first ?? "#FFFFFF"),
            String(colors.second ?? "#000000")
        )
    }

    func cryptoBalance(for wallet: Wallet?, currency: Currency) -> BigInt {
        guard let wallet = wallet else {
            return BigInt.Companion().zero()
        }
        let count = walletsStateService.transactionCount(wallet: wallet)
        return walletsStateService.balance(wallet: wallet, currency: currency)
    }

    func fiatBalance(for wallet: Wallet?, currency: Currency) -> Double {
        let price = currencyMetadataService
            .market(currency: currency)?
            .currentPrice?
            .doubleValue ?? 0
        let amount = currency.double(
            balance: cryptoBalance(for: wallet, currency: currency)
        )
        return price * amount
    }

    func fiatPrice(for wallet: Wallet?, currency: Currency) -> Double {
        currencyMetadataService.market(currency: currency)?
            .currentPrice?
            .doubleValue ?? 0
    }

    func totalFiatBalance() -> Double {
        var total = 0.0
        networksService.walletsForEnabledNetworks().forEach { wallet in
            if let network = wallet.network() {
                currenciesService.currencies(wallet: wallet).forEach {
                    total += fiatBalance(for: wallet, currency: $0)
                }
            }
        }
        return total
    }


    func reloadData() {
        guard let wallet = networksService.wallet() else {
            return
        }

        let allCurrencies = networksService.walletsForEnabledNetworks()
                .map { currenciesService.currencies(wallet: $0) }
                .reduce([Currency](), { $0 + $1 })

        guard allCurrencies.isEmpty == false else {
            return
        }

        currencyMetadataService.refreshMarket(
            currencies: allCurrencies,
            completionHandler: { [weak self] (market, _) in
                DispatchQueue.main.async {
                    self?.emit(.didUpdateMarketInfo(market: market))
                }
            }
        )

        reloadCandles()
        nftsService.fetchNFTs { [weak self] _ in
            self?.emit(.didUpdateNFTs)
        }
    }

    func reloadCandles() {
        guard let wallet = networksService.wallet() else {
            return
        }
        // TODO: Limit to 50 currencies
        networksService.walletsForEnabledNetworks().forEach { wallet in
            currenciesService.currencies(wallet: wallet).forEach { currency in
                currencyMetadataService.candles(
                    currency: currency,
                    completionHandler: { [weak self] (_, _ ) in
                        let event = DashboardInteractorEvent.didUpdateCandles(
                            network: wallet.network() ?? Network.ethereum(),
                            currency: currency)
                        self?.emit(event)
                    }
                )
            }
        }
    }

    @objc func didEnterBackground() {
        walletsStateService.start()
    }

    @objc func willEnterBackground() {
        walletsStateService.pause()
    }
}

// MARK: - Listeners

extension DefaultDashboardInteractor: NetworksListener, WalletsStateListener {


    func addListener(_ listener: DashboardInteractorLister) {
        if listeners.isEmpty {
            networksService.add(listener_: self)
            walletsStateService.add(listener: self)
            updateObservingWalletsState()
        }

        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: DashboardInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            networksService.remove(listener_: nil)
            walletsStateService.remove(listener: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            networksService.remove(listener_: nil)
            walletsStateService.remove(listener: nil)
        }
    }

    private func emit(_ event: DashboardInteractorEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event_ event: NetworksEvent) {
        print("=== NetworksEvent ", event)
        if let networksChanged = event as? NetworksEvent.NetworkDidChange {
            reloadData()
            updateObservingWalletsState()
        }
        emit(event.toInteractorEvent())
    }

    func handle(event: WalletsStateEvent) {
        print("=== NetworksEvent ", event)
        emit(event.toInteractorEvent())
    }

    private class WeakContainer {
        weak var value: DashboardInteractorLister?

        init(_ value: DashboardInteractorLister) {
            self.value = value
        }
    }

    func updateObservingWalletsState() {
        print("=== update observing wallet")
        walletsStateService.stopObserving(wallet: nil)
        networksService.walletsForEnabledNetworks().forEach {
            walletsStateService.observe(
                wallet: $0,
                currencies: currenciesService.currencies(wallet: $0)
            )
            print(
                "=== update observing wallet",
                $0,
                currenciesService.currencies(wallet: $0).count
            )
        }
    }
}


// MARK: - NetworksEvent

extension NetworksEvent {

    func toInteractorEvent() -> DashboardInteractorEvent {
        if let event = self as? NetworksEvent.KeyStoreItemDidChange {
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

extension WalletsStateEvent {

    func toInteractorEvent() -> DashboardInteractorEvent {
        if let event = self as? WalletsStateEvent.Balance {
            return .didUpdateBalance(
                wallet: event.wallet,
                currency: event.currency,
                balance: event.balance
            )
        }
        if let event = self as? WalletsStateEvent.BlockNumber {
            return .didUpdateBlock(blockNumber: event.number)
        }
        if let event = self as? WalletsStateEvent.TransactionCount {
            let (wallet, count) = (event.wallet, event.nonce)
            return .didUpdateTransactionCount(wallet: wallet, count: count)
        }
        fatalError("Unhandled event \(self)")
    }
}
