// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DashboardPresenterEvent {
    case receiveAction
    case sendAction
    case tradeAction
    case walletConnectionSettingsAction
    case didSelectWallet(idx: Int)
    case didSelectNFT(idx: Int)
    case didInteractWithCardSwitcher
    case presentUnderConstructionAlert
    case didTapNetwork
    case didTapEditTokens
}

protocol DashboardPresenter {
    
    func present()
    func handle(_ event: DashboardPresenterEvent)
}

final class DefaultDashboardPresenter {
    
    private weak var view: DashboardView?
    private let interactor: DashboardInteractor
    private let wireframe: DashboardWireframe
    private let onboardingService: OnboardingService
    
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
        
        interactor.addWalletListener(self)
    }
}

extension DefaultDashboardPresenter: DashboardPresenter {
    
    func present() {
        
        fetchMyTokens()
    }
    
    func handle(_ event: DashboardPresenterEvent) {
        switch event {
        case let .didSelectWallet(idx):
            let keyStoreItem = KeyStoreItem.rand()
            wireframe.navigate(to: .wallet(wallet: keyStoreItem, token: myTokens[idx]))
        case .walletConnectionSettingsAction:
            wireframe.navigate(to: .keyStoreNetworkSettings)
        case .didInteractWithCardSwitcher:
            onboardingService.markDidInteractCardSwitcher()
            view?.update(with: viewModel())
        case .presentUnderConstructionAlert:
            wireframe.navigate(to: .presentUnderConstructionAlert)
        case .receiveAction:
            wireframe.navigate(to: .receiveCoins)
        case .sendAction:
            break
        case .didTapEditTokens:
            wireframe.navigate(to: .editTokens(
                selectedTokens: myTokens,
                onCompletion: makeOnEditTokensCompletion()
            )
            )
        default:
            print("Handle \(event)")
        }
    }
}

private extension DefaultDashboardPresenter {
    
    func fetchMyTokens() {
        
        let myTokens = interactor.myTokens
        guard self.myTokens != myTokens else { return }
        self.myTokens = myTokens
        view?.update(with: viewModel())
    }
}

private extension DefaultDashboardPresenter {
    
    func viewModel() -> DashboardViewModel {
        
        let networksAndTokensDict = myTokens.networksAndTokensDict
        
        var sections = [DashboardViewModel.Section]()
        
        Array(networksAndTokensDict.keys).sorted(by: {
            $0.name < $1.name
        }).forEach { network in
            
            let tokens: [Web3Token] = networksAndTokensDict[network] ?? []
            
            sections.append(
                .init(
                    name: network.name,
                    wallets: makeDashboardViewModelWallets(from: tokens),
                    nfts: makeDashboardViewModelNFts(from: interactor.nfts(for: network))
                )
            )
        }
        
        return .init(
            shouldAnimateCardSwitcher: onboardingService.shouldShowOnboardingButton(),
            header: .init(
                balance: "$69,420.00",
                pct: "+4.5%",
                pctUp: true,
                buttons: [
                    .init(
                        title: Localized("dashboard.button.receive"),
                        imageName: "button_receive"
                    ),
                    .init(
                        title: Localized("dashboard.button.send"),
                        imageName: "button_send"
                    ),
                    .init(
                        title: Localized("dashboard.button.trade"),
                        imageName: "button_trade"
                    )
                ],
                firstSection: sections.first?.name ?? ""
            ),
            sections: sections
        )
    }
    
    func makeDashboardViewModelWallets(from tokens: [Web3Token]) -> [DashboardViewModel.Wallet] {
        
        tokens.sortByNetworkBalanceAndName.compactMap {
            
            .init(
                name: $0.name,
                ticker: $0.symbol,
                imageData: interactor.tokenIcon(for: $0),
                fiatBalance: "$69,000",
                cryptoBalance: "\($0.balance) \($0.symbol)",
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

private extension Array where Element == Web3Token {
    
    var networksAndTokensDict: [Web3Network: [Web3Token]] {
        
        var networksDict = [Web3Network: [Web3Token]]()
        
        forEach {
            
            if var tokenArray = networksDict[$0.network] {
                
                tokenArray.append($0)
                networksDict[$0.network] = tokenArray
            } else {
                
                networksDict[$0.network] = [$0]
            }
        }
        
        return networksDict
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
    
    func tokensChanged() {
        
        fetchMyTokens()
    }
}
