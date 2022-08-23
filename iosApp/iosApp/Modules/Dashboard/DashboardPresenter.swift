// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

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
}

protocol DashboardPresenter: AnyObject {
    func present()
    func handle(_ event: DashboardPresenterEvent)
}

final class DefaultDashboardPresenter {
    private weak var view: DashboardView?
    private let interactor: DashboardInteractor
    private let wireframe: DashboardWireframe
    private let onboardingService: OnboardingService

    var expandedNetworks = [String]()
    var notifications = [Web3Notification]()

    init(
        view: DashboardView,
        interactor: DashboardInteractor,
        wireframe: DashboardWireframe,
        onboardingService: OnboardingService
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.onboardingService = onboardingService

        interactor.addListener(self)        
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
            if let wallet = interactor.wallet(for: network) {
                wireframe.navigate(to: .wallet(wallet: wallet, currency: currency))
            }

        case .walletConnectionSettingsAction:
            wireframe.navigate(to: .keyStoreNetworkSettings)
            
        case .didInteractWithCardSwitcher:
            onboardingService.markDidInteractCardSwitcher()
            view?.update(with: viewModel())
            
        case .receiveAction:
            wireframe.navigate(to: .receive)
            
        case .sendAction:
            wireframe.navigate(to: .send(addressTo: nil))
            
        case .didScanQRCode:
            wireframe.navigate(to: .scanQRCode(onCompletion: makeOnQRCodeScanned()))
            
        case let .didTapEditTokens(networkId):
            guard let network = interactor.enabledNetworks().first(where: {
                $0.id() == networkId
            }) else { return }

            let web3Network = Web3Network.from(network, isOn: true)

            wireframe.navigate(
                to: .editTokens(
                    network: web3Network,
                    selectedTokens: interactor.currencies(for: network).map {
                        Web3Token.from(currency: $0, network: web3Network, inWallet: true, idx: 0)
                    },
                    onCompletion: { [weak self] tokens in
                        self?.selectedTokensHandler(tokens, network: web3Network)
                    }
                )
            )
            
        case .swapAction:
            wireframe.navigate(to: .tokenSwap)
            
        case let .didTapNotification(id):
            guard let notification = notifications.first(where: { $0.id == id }) else { return }
            guard let deepLink = DeepLink(identifier: notification.deepLink) else { return }
            wireframe.navigate(to: .deepLink(deepLink))
            
        case .didTapDismissNotification:
            break
        default:
            print("Handle \(event)")
        }
    }
}

extension DefaultDashboardPresenter: DashboardInteractorLister {

    func handle(_ event: DashboardInteractorEvent) {
        switch event {
        case .didUpdateMarketdata, .didUpdateNFTs, .didChangeNetworks, .didUpdateCandles:
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
    
    func viewModel() -> DashboardViewModel {
        var sections = [DashboardViewModel.Section]()
        sections.append(
            .init(
                header: .balance(interactor.totalFiatBalance().formatCurrency() ?? ""),
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

        let nfts = interactor.nfts(for: Web3Network.from(Network.ethereum(), isOn: true))

        if !nfts.isEmpty {
            sections.append(
                .init(
                    header: .title(Localized("dashboard.section.nfts").uppercased()),
                    items: .nfts(nftsViewModel(from: nfts))
                )
            )
        }

        return .init(
            shouldAnimateCardSwitcher: onboardingService.shouldShowOnboardingButton(),
            sections: sections
        )
    }
    
    func notificationViewModel() -> DashboardViewModel.Section.Items {
        
        let items: [DashboardViewModel.Notification] = notifications.compactMap {
            .init(
                id: $0.id,
                image: $0.image,
                title: $0.title,
                body: $0.body,
                canDismiss: $0.canDismiss
            )
        }
        return .notifications(items)
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
            imageName: currency.coinGeckoId ?? "currency_placeholder",
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
        guard let candles = candles else {
            return .loading(40)
        }

        return .loaded(candles.last(n: 40).map { CandlesViewModel.Candle.from($0) })
    }
    
    func nftsViewModel(from nfts: [NFTItem]) -> [DashboardViewModel.NFT] {
        nfts.compactMap { .init(image: $0.image, onSelected: makeOnNFTSelected(for: $0)) }
    }

    func makeOnNFTSelected(for nftItem: NFTItem) -> () -> Void {
        
        {
            [weak self] in
            
            guard let self = self else { return }
            
            self.wireframe.navigate(to: .nftItem(nftItem))
        }
    }

    func selectedTokensHandler(_ tokens: [Web3Token], network: Web3Network) {
        selectedCurrenciesHandler(
            tokens.map { $0.toCurrency() },
            network: network.toNetwork()
        )
    }

    func selectedCurrenciesHandler(_ currencies: [Currency], network: Network) {
        interactor.setCurrencies(currencies, network: network)
        updateView()
        interactor.reloadData()
    }
}


private extension DefaultDashboardPresenter {
    
    func makeOnQRCodeScanned() -> (String) -> Void {
        {
            [weak self] addressTo in
            guard let self = self else { return }
            self.wireframe.navigate(to: .send(addressTo: addressTo))
        }
    }
}
