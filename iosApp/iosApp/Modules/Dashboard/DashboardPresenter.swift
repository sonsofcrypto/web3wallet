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
    case didSelectWallet(network: String, symbol: String)
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
    }

    deinit {
        interactor.removeListener(self)
    }
}

extension DefaultDashboardPresenter: DashboardPresenter {
    
    func present() {
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
            
        case let .didSelectWallet(networkId, symbol):
            guard let token = myTokens.first(
                where: { $0.equalTo(networkId: networkId, symbol: symbol) }
            ) else { return }
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
                    onCompletion: makeOnEditTokensCompletion()
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
        updateView()
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
            
            let tokens = interactor.currencies(for: network).toWeb3TokenList(
                network: Web3Network.from(network, isOn: true)
            )

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
                    items: .wallets(walletViewModel(from: tokens))
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
    
    func walletViewModel(from tokens: [Web3Token]) -> [DashboardViewModel.Wallet] {
        tokens.sortByNetworkBalanceAndName.compactMap {
            .init(
                name: $0.name,
                ticker: $0.symbol,
                imageData: interactor.tokenIcon(for: $0),
                fiatBalance: $0.usdBalanceString,
                cryptoBalance: "\($0.balance.toString(decimals: $0.decimals)) \($0.symbol)",
                tokenPrice: $0.usdPrice.formatCurrency() ?? "",
                pctChange: "4.5%",
                priceUp: true,
                candles: .loaded(interactor.priceData(for: $0).toCandlesViewModelCandle)
            )
        }
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
    
    func makeOnEditTokensCompletion() -> ([Web3Token]) -> Void {
        {
            [weak self] updatedTokens in
            guard let self = self else { return }
            self.interactor.updateMyWeb3Tokens(to: updatedTokens)
        }
    }
}


private extension Array where Element == Web3Candle {
    
    var toCandlesViewModelCandle: [CandlesViewModel.Candle] {
        compactMap {
            .init(
                open: $0.open,
                high: $0.high,
                low: $0.low,
                close: $0.close,
                volume: $0.volume,
                period: $0.period
            )
        }
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
