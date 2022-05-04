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
}

protocol DashboardPresenter {

    func present()
    func handle(_ event: DashboardPresenterEvent)
}

// MARK: - DefaultDashboardPresenter

class DefaultDashboardPresenter {

    private let interactor: DashboardInteractor
    private let wireframe: DashboardWireframe
    private let onboardingService: OnboardingService

    private weak var view: DashboardView?

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
    }
}

// MARK: DashboardPresenter

extension DefaultDashboardPresenter: DashboardPresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: DashboardPresenterEvent) {
        switch event {
        case let .didSelectWallet(idx):
            let keyStoreItem = KeyStoreItem.rand()
            wireframe.navigate(to: .wallet(wallet: keyStoreItem))
        case .walletConnectionSettingsAction:
            wireframe.navigate(to: .keyStoreNetworkSettings)
        case .didInteractWithCardSwitcher:
            onboardingService.markDidInteractCardSwitcher()
            view?.update(with: viewModel())
        case .presentUnderConstructionAlert:
            wireframe.navigate(to: .presentUnderConstructionAlert)
        default:
            print("Handle \(event)")
        }
    }
}

// MARK: - Event handling

private extension DefaultDashboardPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultDashboardPresenter {

    func viewModel() -> DashboardViewModel {
        .init(
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
                firstSection: "Ethereum"
            ),
            sections: [
                .init(
                    name: "Ethereum",
                    wallets: DashboardViewModel.mockWalletsEHT(),
                    nfts: DashboardViewModel.mockNFTsETH()
                ),
                .init(
                    name: "Solana",
                    wallets: DashboardViewModel.mockWalletsSOL(),
                    nfts: DashboardViewModel.mockNFTsSOL()
                )
            ]
        )
    }
}
