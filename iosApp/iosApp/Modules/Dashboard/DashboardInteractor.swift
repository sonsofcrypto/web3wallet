// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum DashboardInteractorEvent {
    case didSelectWallet(wallet: Wallet?)
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
    func nfts(for network: Web3Network) -> [ NFTItem ]

    func enabledNetworks() -> [Network]
    func wallet(for network: Network) -> Wallet?
    func currencies(for network: Network) -> [Currency]
    func setCurrencies(_ currencies: [Currency], network: Network)
    func metadata(for currency: Currency) -> Market?
    func candles(for currency: Currency) -> [Candle]?
    // TODO: Refactor to be url or image name
    func image(for currency: Currency) -> Data
    func cryptoBalance(for wallet: Wallet?, currency: Currency) -> BigInt
    func fiatBalance(for wallet: Wallet?, currency: Currency) -> Double
    func totalFiatBalance() -> Double
    func reloadData()

    func addListener(_ listener: DashboardInteractorLister)
    func removeListener(_ listener: DashboardInteractorLister?)
}

final class DefaultDashboardInteractor {

    private let walletsConnectionService: WalletsConnectionService
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService
    private let walletsStateService: WalletsStateService
    private let web3ServiceLegacy: Web3ServiceLegacy
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService
    private var listeners: [WeakContainer] = []

    init(
        walletsConnectionService: WalletsConnectionService,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService,
        walletsStateService: WalletsStateService,
        web3ServiceLegacy: Web3ServiceLegacy,
        priceHistoryService: PriceHistoryService,
        nftsService: NFTsService
    ) {
        self.web3ServiceLegacy = web3ServiceLegacy
        self.walletsConnectionService = walletsConnectionService
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
        walletsConnectionService.enabledNetworks()
    }

    func wallet(for network: Network) -> Wallet? {
        walletsConnectionService.wallet(network: network)
    }

    func currencies(for network: Network) -> [Currency] {
        guard let wallet = walletsConnectionService.wallet(network: network) else {
            return []
        }

        return currenciesService.currencies(wallet: wallet)
    }

    func setCurrencies(_ currencies: [Currency], network: Network) {
        guard let wallet = walletsConnectionService.wallet(network: network) else {
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
            image = UIImage(named: id + "_large")
        }

        image = image ?? UIImage(named: "currency_placeholder")
        return image!.pngData()!
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

    func totalFiatBalance() -> Double {
        var total = 0.0
        walletsConnectionService.walletsForAllNetwork().forEach { wallet in
            if let network = wallet.network() {
                currenciesService.currencies(wallet: wallet).forEach {
                    total += fiatBalance(for: wallet, currency: $0)
                }
            }
        }
        return total
    }


    func reloadData() {
        guard let wallet = walletsConnectionService.wallet else {
            return
        }

        let allCurrencies = walletsConnectionService.walletsForAllNetwork()
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
        nftsService.fetchNFTs { _ in }
    }

    func reloadCandles() {
        guard let wallet = walletsConnectionService.wallet else {
            return
        }
        // TODO: Limit to 50 currencies
        walletsConnectionService.walletsForAllNetwork().forEach { wallet in
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

extension DefaultDashboardInteractor: WalletsConnectionListener, WalletsStateListener {

    func addListener(_ listener: DashboardInteractorLister) {
        if listeners.isEmpty {
            walletsConnectionService.add(listener: self)
            walletsStateService.add(listener_: self)
            updateObservingWalletsState()
        }

        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: DashboardInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            walletsConnectionService.remove(listener: nil)
            walletsStateService.remove(listener_: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            walletsConnectionService.remove(listener: nil)
            walletsStateService.remove(listener_: nil)
        }
    }

    private func emit(_ event: DashboardInteractorEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event: WalletsConnectionEvent) {
        print("=== WalletsConnectionEvent ", event)
        if let networksChanged = event as? WalletsConnectionEvent.NetworksChanged {
            reloadData()
            updateObservingWalletsState()
        }
        emit(event.toInteractorEvent())
    }

    func handle(event_ event: WalletsStateEvent) {
        print("=== WalletsConnectionEvent ", event)
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
        walletsConnectionService.walletsForAllNetwork().forEach {
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


// MARK: - WalletsConnectionEvent

extension WalletsConnectionEvent {

    func toInteractorEvent() -> DashboardInteractorEvent {
        if let event = self as? WalletsConnectionEvent.WalletSelected {
            return .didSelectWallet(wallet: event.wallet)
        }
        if let event = self as? WalletsConnectionEvent.NetworkSelected {
            return .didSelectNetwork(network: event.network)
        }
        if let event = self as? WalletsConnectionEvent.NetworksChanged {
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
