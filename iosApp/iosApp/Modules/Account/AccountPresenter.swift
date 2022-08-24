// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum AccountPresenterEvent {
    case receive
    case send
    case swap
    case more
}

protocol AccountPresenter {
    func present()
    func handle(_ event: AccountPresenterEvent)
}

final class DefaultAccountPresenter {
    private weak var view: AccountView?
    private let interactor: AccountInteractor
    private let wireframe: AccountWireframe
    private let context: AccountWireframeContext

    init(
        view: AccountView,
        interactor: AccountInteractor,
        wireframe: AccountWireframe,
        context: AccountWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultAccountPresenter: AccountPresenter {

    func present() {
        updateView()
        interactor.fetchTransactions{ [weak self] _ in  self?.updateView() }
    }

    func updateView() {
        view?.update(with: viewModel())
    }

    func handle(_ event: AccountPresenterEvent) {
        switch event {
        case .receive:
            wireframe.navigate(to: .receive)
        case .send:
            wireframe.navigate(to: .send)
        case .swap:
            wireframe.navigate(to: .swap)
        case .more:
            wireframe.navigate(to: .more)
        }
    }
}

private extension DefaultAccountPresenter {

    func viewModel() -> AccountViewModel {
        let currency = interactor.currency()
        let market = interactor.market()
        let pct = market?.priceChangePercentage24h
        
        return .init(
            currencyName: currency.name,
            header: .init(
                balance: Formatter.currency.string(
                    interactor.cryptoBalance(),
                    currency: currency,
                    style: .long(minDecimals: 8)
                ),
                fiatBalance: Formatter.fiat.string(interactor.fiatBalance()),
                pct: Formatter.pct.string(pct, div: true),
                pctUp: market?.priceChangePercentage24h?.doubleValue ?? 0 >= 0,
                buttons: headerButtonViewModels()
            ),
            candles: .loaded(
                CandlesViewModel.Candle.from(interactor.candles()?.last(n: 90))
            ),
            marketInfo: .init(
                marketCap: Formatter.fiat.string(market?.marketCap),
                price: Formatter.fiat.string(market?.currentPrice),
                volume: Formatter.fiat.string(market?.totalVolume)
            ),
            bonusAction: currency.symbol == "cult"
                ? AccountViewModel.BonusAction(title: "Read the manifesto")
                : nil,
            transactions: interactor.transactions().map {
                transactionViewModel($0)
            }
        )
    }

    func headerButtonViewModels() -> [AccountViewModel.Header.Button] {
        [
            .init(title: Localized("receive"), imageName: "receive_large".themeImage),
            .init(title: Localized("send"), imageName: "send_large".themeImage),
            .init(title: Localized("swap"), imageName: "swap_large".themeImage),
            .init(title: Localized("more"), imageName: "more_large".themeImage)
        ]
    }

    func transactionViewModel(
        _ transaction: AccountInteractorTransaction
    ) -> AccountViewModel.Transaction {
         AccountViewModel.Transaction(
            date: transaction.date == nil
                ? transaction.blockNumber
                : Formatter.date.string(transaction.date),
            address: transaction.address,
            amount: transaction.amount,
            isReceive: transaction.isReceive
        )
    }
}
