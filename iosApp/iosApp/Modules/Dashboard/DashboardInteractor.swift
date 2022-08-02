// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum DashboardInteractorEvent {
    case didSelectWallet
    case didSelectNetwork
    case didChaneNetwork
    case didUpdateBlock
    case didUpdatePriceData
    case didUpdateCandles(network: Network, currency: Currency)
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
    func updateMyWeb3Tokens(to tokens: [Web3Token])

    func enabledNetworks() -> [Network]
    func currencies(for network: Network) -> [Currency]
    func setCurrencies(_ currencies: [Currency], network: Network)
    func metadata(for currency: Currency) -> Market?
    func candles(for currency: Currency) -> [Candle]?
    // TODO: Refactor to be url or image name
    func image(for currency: Currency) -> Data
    func totalBalanceInFiat() -> Double
    func reloadData()

    func addListener(_ listener: DashboardInteractorLister)
    func removeListener(_ listener: DashboardInteractorLister?)
}

final class DefaultDashboardInteractor {

    private let web3service: Web3Service
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService
    private let web3ServiceLegacy: Web3ServiceLegacy
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService
    private var listeners: [WeakContainer] = []

    init(
        web3service: Web3Service,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService,
        web3ServiceLegacy: Web3ServiceLegacy,
        priceHistoryService: PriceHistoryService,
        nftsService: NFTsService
    ) {
        self.web3ServiceLegacy = web3ServiceLegacy
        self.web3service = web3service
        self.currenciesService = currenciesService
        self.currencyMetadataService = currencyMetadataService
        self.priceHistoryService = priceHistoryService
        self.nftsService = nftsService
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

    func updateMyWeb3Tokens(to tokens: [Web3Token]) {
        web3ServiceLegacy.storeMyTokens(to: tokens)
    }
}

extension DefaultDashboardInteractor {

    func enabledNetworks() -> [Network] {
        web3service.enabledNetworks()
    }

    func currencies(for network: Network) -> [Currency] {
        guard let wallet = web3service.wallet else {
            return []
        }

        return currenciesService.currencies(wallet: wallet, network: network)
    }

    func setCurrencies(_ currencies: [Currency], network: Network) {
        guard let wallet = web3service.wallet else {
            return
        }

        currenciesService.setSelected(
            currencies: currencies,
            wallet: wallet,
            network: network
        )
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

    func reloadData() {
        guard let wallet = web3service.wallet else {
            return
        }

        let allCurrencies = web3service.enabledNetworks()
                .map { currenciesService.currencies(wallet: wallet, network: $0) }
                .reduce([Currency](), { $0 + $1 })

        guard allCurrencies.isEmpty == false {
            return
        }

        currencyMetadataService.refreshMarket(
            currencies: allCurrencies,
            completionHandler: { [weak self] (_, _) in
                DispatchQueue.main.async {
                    self?.emit(.didUpdatePriceData)
                }
            }
        )

        reloadCandles()


        // TODO: Get balance
        // TODO: Refresh nfts
    }

    func reloadCandles() {
        guard let wallet = web3service.wallet else {
            return
        }
        // TODO: Limit to 50 currencies
        web3service.enabledNetworks().forEach { network in
            currenciesService.currencies(
                wallet: wallet,
                network: network
            ).forEach { currency in
                currencyMetadataService.candles(
                    currency: currency,
                    completionHandler: { [weak self] (_, _ ) in
                        let event = DashboardInteractorEvent.didUpdateCandles(
                            network: network,
                            currency: currency)
                        self?.emit(event)
                    }
                )
            }
        }
    }

    func totalBalanceInFiat() -> Double {
        // TODO: Total balance
        return 4235.20
    }
}

// MARK: - Listeners

extension DefaultDashboardInteractor: Web3ServiceListener {

    func addListener(_ listener: DashboardInteractorLister) {
        if listeners.isEmpty {
            web3service.addListener(listener: self)
        }

        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: DashboardInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            web3service.removeListener(listener: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            web3service.removeListener(listener: nil)
        }
    }

    private func emit(_ event: DashboardInteractorEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event: Web3ServiceEvent) {
        print("=== got event", event)
        if let networksChanged = event as? Web3ServiceEvent.NetworksChanged {
            reloadData()
        }
        emit(event.toInteractorEvent())
    }

    private class WeakContainer {
        weak var value: DashboardInteractorLister?

        init(_ value: DashboardInteractorLister) {
            self.value = value
        }
    }
}


// MARK: - Web3ServiceEvent

extension Web3ServiceEvent {

    func toInteractorEvent() -> DashboardInteractorEvent {
        switch self {
        case is Web3ServiceEvent.WalletSelected:
            return .didSelectWallet
        case is Web3ServiceEvent.NetworkSelected:
            return .didSelectNetwork
        case is Web3ServiceEvent.NetworksChanged:
            return .didChaneNetwork
        case is Web3ServiceEvent.BlockUpdated:
            return .didUpdateBlock
        default:
            fatalError("Unhandled event \(self)")
        }
    }
}
