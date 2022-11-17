// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum DashboardPresenterEvent {
    case receiveAction
    case sendAction
    case swapAction
    case walletConnectionSettingsAction
    case didTapCollapse(network: String)
    case didTapExpand(network: String)
    case didSelectWallet(networkIdx: Int, currencyIdx: Int)
    case didSelectNFT(idx: Int)
    case didInteractWithCardSwitcher
    case didTapNetwork
    case didScanQRCode
    case didTapEditTokens(network: String)
    case didTapAction(idx: Int)
    case didTapDismissNotification(id: String)
    case pullDownToRefresh
}

protocol DashboardPresenter: AnyObject {
    func present()
    func handle(_ event: DashboardPresenterEvent)
    func releaseResources()
}

final class DefaultDashboardPresenter {
    private weak var view: DashboardView?
    private let wireframe: DashboardWireframe
    private let interactor: DashboardInteractor

    var updateTimer: Timer?
    var expandedNetworks = [String]()
    var actions = [Action]()

    init(
        view: DashboardView,
        wireframe: DashboardWireframe,
        interactor: DashboardInteractor
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        interactor.addListener(self)
    }
}

extension DefaultDashboardPresenter: DashboardPresenter {
    
    func present() {
        interactor.reloadData()
        updateView()
    }
    
    func handle(_ event: DashboardPresenterEvent) {
        switch event {
        case let .didTapCollapse(network):
            expandedNetworks.removeAll { $0 == network }
            view?.update(with: viewModel())
        case let .didTapExpand(network):
            expandedNetworks.append(network)
            view?.update(with: viewModel())
        case let .didSelectWallet(networkIdx, currencyIdx):
            let network = interactor.enabledNetworks()[networkIdx]
            let currency = interactor.currencies(for: network)[currencyIdx]
            wireframe.navigate(to: .wallet(network: network, currency: currency))
        case .walletConnectionSettingsAction:
            wireframe.navigate(to: .keyStoreNetworkSettings)
        case .didInteractWithCardSwitcher:
            view?.update(with: viewModel())
        case .receiveAction:
            wireframe.navigate(to: .receive)
        case .sendAction:
            wireframe.navigate(to: .send(addressTo: nil))
        case .didScanQRCode:
            wireframe.navigate(to: .scanQRCode)
        case let .didTapEditTokens(networkId):
            didTapEditToken(networkId)
        case .swapAction:
            wireframe.navigate(to: .tokenSwap)
        case let .didTapAction(idx):
            didTapAction(idx)
        case .didTapDismissNotification:
            break
        case .pullDownToRefresh:
            interactor.reloadData()
        default:
            print("Handle \(event)")
        }
    }
    
    func releaseResources() {
        interactor.removeListener(self)
    }
}

extension DefaultDashboardPresenter: DashboardInteractorLister {

    func handle(_ event: DashboardInteractorEvent) {
        switch event {
        case .didUpdateBalance, .didUpdateMarketdata, .didUpdateNFTs,
             .didUpdateCandles, .didSelectKeyStoreItem, .didSelectNetwork,
             .didChangeNetworks, .didUpdateActions:
            setNeedsUpdateView()
        default:
            ()
        }
    }
}

private extension DefaultDashboardPresenter {
    
    func updateView() {
        actions = interactor.actions()
        view?.update(with: viewModel())
    }

    func setNeedsUpdateView() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false,
            block: { [weak self] _ in self?.updateView() }
        )
    }
}

private extension DefaultDashboardPresenter {
    
    func didTapEditToken(_ networkId: String) {
        let network = interactor.enabledNetworks().first { networkId == $0.id() }
        guard let network = network else { return }
        wireframe.navigate(
            to: .editCurrencies(
                network: network,
                selectedCurrencies: interactor.currencies(for: network),
                onCompletion: { [weak self] currencies in
                    self?.selectedCurrenciesHandler(currencies, network: network)
                }
            )
        )
    }
    
    func didTapAction(_ idx: Int) {
        guard let deepLink = DeepLink(identifier: actions[idx].deepLink) else { return }
        if deepLink.identifier == DeepLink.themesList.identifier {
            wireframe.navigate(to: .themePicker)
        } else {
            wireframe.navigate(to: .deepLink(deepLink))
        }
    }
}

private extension DefaultDashboardPresenter {
    
    func viewModel() -> DashboardViewModel {
        var sections = [DashboardViewModel.Section]()
        sections.append(
            .init(
                header: .balance(
                    Formatters.Companion.shared.fiat.format(
                        amount: interactor.totalFiatBalance().bigDec,
                        style: Formatters.StyleCustom(maxLength: 15),
                        currencyCode: "usd"
                    )
                ),
                items: .buttons(
                    [
                        .init(
                            title: Localized("dashboard.button.receive"),
                            imageName: "receive-button".themeImage,
                            type: .receive
                        ),
                        .init(
                            title: Localized("dashboard.button.send"),
                            imageName: "send-button".themeImage,
                            type: .send
                        ),
                        .init(
                            title: Localized("dashboard.button.swap"),
                            imageName: "swap-button".themeImage,
                            type: .swap
                        )
                    ]
                )
            )
        )
        sections.append(
            .init(
                header: .title(Localized("dashboard.section.notifications")),
                items: notificationViewModel()
            )
        )
        for network in interactor.enabledNetworks() {
            sections.append(
                .init(
                    header: .network(
                        .init(
                            id: network.id(),
                            name: network.name,
                            fuelCost: "", // TODO: Add gas price
                            rightActionTitle: Localized("more").uppercased(),
                            isCollapsed: false // !expandedNetworks.contains(network.name),
                        )
                    ),
                    items: .wallets(
                        interactor.currencies(for: network).map {
                            walletViewModel(network, currency: $0)
                        }
                    )
                )
            )
        }
        let nfts = interactor.nfts(for: Network.ethereum())
        if !nfts.isEmpty {
            sections.append(
                .init(
                    header: .title(Localized("dashboard.section.nfts").uppercased()),
                    items: .nfts(nftsViewModel(from: nfts))
                )
            )
        }
        return .init(
            shouldAnimateCardSwitcher: false,
            sections: sections
        )
    }
    
    func notificationViewModel() -> DashboardViewModel.Section.Items {
        .actions(
            actions.compactMap {
                .init(
                    image: $0.imageName,
                    title: $0.title,
                    body: $0.body,
                    canDismiss: $0.canDismiss
                )
            }
        )
    }

    func walletViewModel(_ network: Network, currency: Currency) -> DashboardViewModel.Wallet {
        let market = interactor.marketdata(for: currency)
        let metadata = interactor.metadata(for: currency)
        let fiatPrice = market?.currentPrice?.doubleValue ?? 0.0
        let fiatBalance = interactor.fiatBalance(for: network, currency: currency)
        let cryptoBalance = interactor.cryptoBalance(for: network, currency: currency)
        return .init(
            name: currency.name,
            ticker: currency.symbol.uppercased(),
            colors: metadata?.colors ?? ["#FFFFFF", "#000000"],
            imageName: currency.iconName,
            fiatPrice: FiatFormatterViewModel(amount: fiatPrice.bigDec, currencyCode: "usd"),
            fiatBalance: FiatFormatterViewModel(amount: fiatBalance.bigDec(decimals: 2), currencyCode: "usd"),
            cryptoBalance: CurrencyFormatterViewModel(amount: cryptoBalance, currency: currency),
            pctChange: Formatters.Companion.shared.pct.format(
                amount: market?.priceChangePercentage24h, div: true
            ),
            priceUp: market?.priceChangePercentage24h?.doubleValue ?? 0 >= 0,
            candles: candlesViewModel(candles: interactor.candles(for: currency))
        )
    }

    func candlesViewModel(candles: [Candle]?) -> CandlesViewModel {
        guard let candles = candles else { return CandlesViewModel.Loading(cnt: 40.int32) }
        return CandlesViewModel.Loaded(candles: candles.last(n: 40).map {
            CandlesViewModel.from($0)
        })
    }
    
    func nftsViewModel(from nfts: [NFTItem]) -> [DashboardViewModel.NFT] {
        nfts.compactMap { .init(image: $0.image, onSelected: makeOnNFTSelected(for: $0)) }
    }

    func makeOnNFTSelected(for nftItem: NFTItem) -> () -> Void {
        { [weak self] in self?.wireframe.navigate(to: .nftItem(nftItem)) }
    }

    func selectedCurrenciesHandler(_ currencies: [Currency], network: Network) {
        interactor.setCurrencies(currencies, network: network)
        updateView()
        interactor.reloadData()
    }
}

private extension CandlesViewModel {
    static func from(_ candle: web3walletcore.Candle) -> CandlesViewModel.Candle {
           CandlesViewModel.Candle(
               open: candle.open,
               high: candle.high,
               low: candle.low,
               close: candle.close,
               volume: 0,
               period: Double(Int(candle.timestamp.epochSeconds))
           )
       }
}
