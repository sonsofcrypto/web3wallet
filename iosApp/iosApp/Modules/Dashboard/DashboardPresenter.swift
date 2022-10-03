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
    case didTapNotification(id: String)
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
    // TODO: @Annon move to web3lib listening for mnemonic updates notifications
    private let web3ServiceLegacy: Web3ServiceLegacy

    var expandedNetworks = [String]()
    var notifications = [Web3Notification]()

    init(
        view: DashboardView,
        wireframe: DashboardWireframe,
        interactor: DashboardInteractor,
        web3ServiceLegacy: Web3ServiceLegacy = AppAssembler.resolve()
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.web3ServiceLegacy = web3ServiceLegacy
        interactor.addListener(self)
        web3ServiceLegacy.addWalletListener(self)
    }

    deinit {
        interactor.removeListener(self)
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
            wireframe.navigate(to: .scanQRCode(onCompletion: onQRCodeScanned()))
        case let .didTapEditTokens(networkId):
            didTapEditToken(networkId)
        case .swapAction:
            wireframe.navigate(to: .tokenSwap)
        case let .didTapNotification(id):
            didTapNotification(id)
        case .didTapDismissNotification:
            break
        case .pullDownToRefresh:
            // Currencies balance & reload market data
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.updateView()
            }
        default:
            print("Handle \(event)")
        }
    }
    
    func releaseResources() {
        web3ServiceLegacy.removeWalletListener(self)
    }
}

extension DefaultDashboardPresenter: DashboardInteractorLister {

    func handle(_ event: DashboardInteractorEvent) {
        switch event {
        case .didUpdateBalance, .didUpdateMarketdata, .didUpdateNFTs,
             .didUpdateCandles, .didSelectKeyStoreItem, .didSelectNetwork,
             .didChangeNetworks:
            updateView()
        default:
            ()
        }
    }
}

private extension DefaultDashboardPresenter {
    
    func updateView() {
        notifications = interactor.notifications()
        view?.update(with: viewModel())
    }
}

private extension DefaultDashboardPresenter {
    
    func didTapEditToken(_ networkId: String) {
        guard let network = interactor.selectedNetwork else { return }
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
    
    func didTapNotification(_ id: String) {
        guard let notification = notifications.first(where: { $0.id == id }) else { return }
        guard let deepLink = DeepLink(identifier: notification.deepLink) else { return }
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
                    Formatter.fiat.string(interactor.totalFiatBalance())
                ),
                items: .actions(
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
        .notifications(
            notifications.compactMap {
                .init(
                    id: $0.id,
                    image: $0.image,
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
        let cryptoBalance = interactor.cryptoBalance(
            for: network,
            currency: currency
        )
        let fiatBalance = interactor.fiatBalance(
            for: network,
            currency: currency
        )
        let formatted = Formatter.currency.string(
            cryptoBalance,
            currency: currency,
            style: .long
        )
        return .init(
            name: currency.name,
            ticker: currency.symbol.uppercased(),
            colors: metadata?.colors ?? ["#FFFFFF", "#000000"],
            imageName: currency.iconName,
            fiatPrice: Formatter.fiat.string(Float(truncating: market?.currentPrice ?? 0)),
            fiatBalance: Formatter.fiat.string(Float(fiatBalance)),
            cryptoBalance: formatted,
            tokenPrice: Formatter.fiat.string(market?.currentPrice),
            pctChange: Formatter.pct.string(market?.priceChangePercentage24h, div: true),
            priceUp: market?.priceChangePercentage24h?.doubleValue ?? 0 >= 0,
            candles: candlesViewModel(candles: interactor.candles(for: currency))
        )
    }

    func candlesViewModel(candles: [Candle]?) -> CandlesViewModel {
        guard let candles = candles else { return .loading(40) }
        return .loaded(candles.last(n: 40).map { CandlesViewModel.Candle.from($0) })
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

private extension DefaultDashboardPresenter {
    
    func onQRCodeScanned() -> (String) -> Void {
        { [weak self] addressTo in self?.wireframe.navigate(to: .send(addressTo: addressTo)) }
    }
}

extension DefaultDashboardPresenter: Web3ServiceWalletListener {
    
    func notificationsChanged() { updateView() }
}
