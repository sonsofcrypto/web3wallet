// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AccountPresenterEvent {

    case receive
}

protocol AccountPresenter {

    func present()
    func handle(_ event: AccountPresenterEvent)
}

final class DefaultAccountPresenter {

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

extension DefaultAccountPresenter: AccountPresenter {

    func present() {
        view?.update(with: viewModel(interactor.wallet, token: interactor.token))
    }

    func handle(_ event: AccountPresenterEvent) {

        switch event {
        case .receive:
            wireframe.navigate(to: .receive)
        }
    }
}

private extension DefaultAccountPresenter {

}

private extension DefaultAccountPresenter {

    func viewModel(_ wallet: KeyStoreItem, token: Web3Token) -> AccountViewModel {
        .init(
            currencyName: token.name,
            header: .init(
                balance: (token.symbol == "CULT" ? "20,000" : "4.20 ") + token.symbol,
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
            candles: .loaded(interactor.priceData(for: token).toCandlesViewModelCandle),
            marketInfo: .init(
                marketCap: "$460,432,599",
                price: "$4200",
                volume: "$68,234,352"
            ),
            bonusAction: token.symbol == "CULT" ? .init(title: "Read the manifesto") : nil,
            transactions: [
                .init(
                    date: "23 Feb 2022",
                    address: "0xcf6fa3373c3ed7e0c2f502e39be74fd4d6f054ee",
                    amount: "+ 6.90 " + token.symbol,
                    isReceive: true
                ),
                .init(
                    date: "14 Jan 2022",
                    address: "0xcf6fa3373c3ed7e0c2f502e39be74fd4d6f054ee",
                    amount: "- 4.20 " + token.symbol,
                    isReceive: false
                )
            ]
        )
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
