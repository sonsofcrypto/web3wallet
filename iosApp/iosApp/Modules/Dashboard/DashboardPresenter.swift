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
    // TODD(Anon): Refactor to shared formatters
    private let fiatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        return formatter
    }()
    // TODD(Anon): Refactor to shared formatters
    private let pctFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    var expandedNetworks = [String]()
    var notifications = [Web3Notification]()
    var myTokens = [Web3Token]()
    
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
        interactor.addLegacyListener(self)
    }

    deinit {
        interactor.removeListener(self)
        interactor.removeLegacyListener(self)
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
            let token = Web3Token.from(
                currency: currency,
                network: Web3Network.from(network, isOn: true),
                inWallet: true,
                idx: currencyIdx
            )
            wireframe.navigate(to: .wallet(token: token))
            
        case .walletConnectionSettingsAction:
            wireframe.navigate(to: .keyStoreNetworkSettings)
            
        case .didInteractWithCardSwitcher:
            onboardingService.markDidInteractCardSwitcher()
            view?.update(with: viewModel())
            
        case .receiveAction:
            wireframe.navigate(to: .receiveCoins)
            
        case .sendAction:
            wireframe.navigate(to: .sendCoins)
            
        case .didScanQRCode:
            wireframe.navigate(to: .scanQRCode(onCompletion: makeOnQRCodeScanned()))
            
        case let .didTapEditTokens(networkId):
            guard let network = interactor.allNetworks.first(where: {
                $0.id == networkId
            }) else { return }

            wireframe.navigate(
                to: .editTokens(
                    network: network,
                    selectedTokens: myTokens,
                    onCompletion: { [weak self] tokens in
                        self?.selectedTokensHandler(tokens, network: network)
                    }
                )
            )
            
        case .swapAction:
            wireframe.navigate(to: .tokenSwap)
            
        case let .didTapNotification(id):
            guard let notification = notifications.first(where: { $0.id == id }) else { return }
            guard let deepLink = DeepLink(rawValue: notification.deepLink) else { return }
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
        case .didUpdateMarketInfo:
            updateView()
        case let .didUpdateCandles(network, currency):
            // TODO(Anon): We dont need to construct viewModel here
            // TODO(Anon): Refactor ugly AF
            let section = interactor.enabledNetworks().firstIndex(where: { $0 == network })
            let item = interactor.currencies(for: network).firstIndex(where: { $0 == currency })
            if let section = section, let item = item {
                let viewModel = viewModel()
                view?.updateWallet(
                    viewModel.sections[section + 2].items.wallet(at: item),
                    at: IndexPath(item: item, section: section + 2)
                )
            }
        default:
            ()
        }
    }
}

private extension DefaultDashboardPresenter {
    
    func updateView() {
        
        self.notifications = interactor.notifications
        self.myTokens = interactor.myTokens
        view?.update(with: viewModel())
    }
}

private extension DefaultDashboardPresenter {
    
    func viewModel() -> DashboardViewModel {
        var sections = [DashboardViewModel.Section]()
        var nfts = [DashboardViewModel.NFT]()

        sections.append(
            .init(
                header: .balance(interactor.totalBalanceInFiat().formatCurrency() ?? ""),
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
                items: makeNotificationItems()
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
                        walletsViewModel(from: interactor.currencies(for: network))
                    )
                )
            )
        }

        if !nfts.isEmpty {
            sections.append(
                .init(
                    header: .title(
                        Localized("dashboard.section.nfts").uppercased()
                    ),
                    items: .nfts(nfts)
                )
            )
        }

        return .init(
            shouldAnimateCardSwitcher: onboardingService.shouldShowOnboardingButton(),
            sections: sections
        )
    }
    
    func makeNotificationItems() -> DashboardViewModel.Section.Items {
        
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
    
    func walletsViewModel(from currencies: [Currency]) -> [DashboardViewModel.Wallet] {
        currencies.map {
            walletViewModel(
                $0,
                market: interactor.metadata(for: $0)
            )
        }
    }

    func walletViewModel(_ currency: Currency, market: Market?) -> DashboardViewModel.Wallet {
        .init(
            name: currency.name,
            ticker: currency.symbol,
            imageData: interactor.image(for: currency),
            fiatBalance: "0", // $0.usdBalanceString,
            cryptoBalance: "0", // "\($0.balance.toString(decimals: $0.decimals)) \($0.symbol)",
            tokenPrice: market?.currentPrice != nil
                ? fiatFormatter.string(from: market?.currentPrice ?? 0) ?? "-"
                : "-",
            pctChange: market?.priceChangePercentage24h != nil
                ? pctFormatter.string(from: Float(market?.priceChangePercentage24h ?? 0) * 0.01) ?? "-"
                : "-",
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
    
    func makeDashboardViewModelNFts(from nfts: [NFTItem]) -> [DashboardViewModel.NFT] {
        
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

extension DefaultDashboardPresenter: Web3ServiceWalletListener {
    
    func notificationsChanged() {
        updateView()
    }
    
    func nftsChanged() {
        updateView()
    }
    
    func tokensChanged() {
        updateView()
    }
}

private extension DefaultDashboardPresenter {
    
    func makeOnQRCodeScanned() -> (String) -> Void {
        {
            [weak self] qrCode in
            guard let self = self else { return }
            // TODO: @Annon Check here what to do with the code?
            print("QR code scanned: \(qrCode)")
        }
    }
}
