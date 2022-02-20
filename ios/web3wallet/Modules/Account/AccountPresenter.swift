// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AccountPresenterEvent {

}

protocol AccountPresenter {

    func present()
    func handle(_ event: AccountPresenterEvent)
}

// MARK: - DefaultAccountPresenter

class DefaultAccountPresenter {

    private let interactor: AccountInteractor
    private let wireframe: AccountWireframe

    // private var items: [Item]

    private weak var view: AccountView?

    init(
        view: AccountView,
        interactor: AccountInteractor,
        wireframe: AccountWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: AccountPresenter

extension DefaultAccountPresenter: AccountPresenter {

    func present() {
        view?.update(with: viewModel(interactor.wallet))
    }

    func handle(_ event: AccountPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultAccountPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultAccountPresenter {

    func viewModel(_ wallet: Wallet) -> AccountViewModel {
        .init(
            currencyName: "Ethereum",
            header: .init(
                balance: "4.20 ETH",
                fiatBalance: "$6,900",
                pct: "+4.5%",
                pctUp: true,
                buttons: [
                    .init(title: Localized("receive"), imageName: "button_receive"),
                    .init(title: Localized("send"), imageName: "button_send"),
                    .init(title: Localized("trade"), imageName: "button_trade"),
                    .init(title: Localized("more"), imageName: "button_more")
                ]
            ),
            candles: CandlesViewModel.mock(50, first: false),
            marketInfo: .init(
                marketCap: "$460,432,599",
                price: "$4200",
                volume: "$68,234,352"
            ),
            transactions: [
                .init(
                    date: "23 Feb 2022",
                    address: "0xcf6fa3373c3ed7e0c2f502e39be74fd4d6f054ee",
                    amount: "+ 6.90 ETH",
                    isReceive: true
                ),
                .init(
                    date: "14 Jan 2022",
                    address: "0xcf6fa3373c3ed7e0c2f502e39be74fd4d6f054ee",
                    amount: "- 4.20 ETH",
                    isReceive: false
                )
            ]
        )
    }
}
