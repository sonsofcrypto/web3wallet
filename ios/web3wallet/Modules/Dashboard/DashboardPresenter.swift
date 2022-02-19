// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DashboardPresenterEvent {
    case receiveAction
    case sendAction
    case tradeAction
    case didSelectWallet(idx: Int)
    case didSelectNFT(idx: Int)

}

protocol DashboardPresenter {

    func present()
    func handle(_ event: DashboardPresenterEvent)
}

// MARK: - DefaultDashboardPresenter

class DefaultDashboardPresenter {

    private let interactor: DashboardInteractor
    private let wireframe: DashboardWireframe

    private weak var view: DashboardView?

    init(
        view: DashboardView,
        interactor: DashboardInteractor,
        wireframe: DashboardWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: DashboardPresenter

extension DefaultDashboardPresenter: DashboardPresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: DashboardPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultDashboardPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultDashboardPresenter {

    func viewModel() -> DashboardViewModel {
        .init(
            header: .init(
                balance: "$69,420.00",
                pct: "+4.5%",
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
