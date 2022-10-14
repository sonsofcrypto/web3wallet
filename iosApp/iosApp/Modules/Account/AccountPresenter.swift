// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum AccountPresenterEvent {
    case receive
    case send
    case swap
    case more
    case pullDownToRefresh
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
        wireframe: AccountWireframe,
        interactor: AccountInteractor,
        context: AccountWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultAccountPresenter: AccountPresenter {

    func present() {
        updateView()
        interactor.fetchTransactions{ [weak self] _ in  self?.updateView() }
    }

    func handle(_ event: AccountPresenterEvent) {
        switch event {
        case .receive: wireframe.navigate(to: .receive)
        case .send: wireframe.navigate(to: .send)
        case .swap: wireframe.navigate(to: .swap)
        case .more: wireframe.navigate(to: .more)
        case .pullDownToRefresh:
            interactor.fetchTransactions{ [weak self] _ in self?.updateView() }
        }
    }
}

private extension DefaultAccountPresenter {
    
    func updateView() {
        view?.update(with: viewModel())
    }

    func viewModel() -> AccountViewModel {
        let currency = interactor.currency()
        let market = interactor.market()
        let pct = market?.priceChangePercentage24h
        return .init(
            currencyName: currency.name,
            header: .init(
                balance: Formatters.Companion.shared.currency.format(
                    amount: interactor.cryptoBalance(),
                    currency: currency,
                    style: Formatters.StyleCustom(maxLength: 15)
                ),
                fiatBalance: Formatter.fiat.string(interactor.fiatBalance()),
                pct: Formatter.pct.string(pct, div: true),
                pctUp: market?.priceChangePercentage24h?.doubleValue ?? 0 >= 0,
                buttons: headerButtonViewModels()
            ),
            address: .init(
                address: interactor.address(),
                copyIcon: "square.on.square"
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
            transactions: makeTransactions()
        )
    }
    
    func makeTransactions() -> [AccountViewModel.Transaction] {
        var transactions = interactor.transactions().map {
            transactionViewModel($0)
        }
        if transactions.isEmpty && !interactor.loadingTransactions {
            return [.empty(text: Localized("account.marketInfo.transactions.empty"))]
        }
        if interactor.loadingTransactions {
            transactions.insert(
                .loading(text: Localized("account.marketInfo.transactions.loading")),
                at: 0
            )
        }
        return transactions
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
        .data(
            .init(
                date: transaction.date == nil
                    ? transaction.blockNumber
                    : Formatter.date.string(transaction.date),
                address: Formatter.address.string(
                    transaction.address,
                    digits: 14,
                    for: interactor.network
                ),
                amount: transaction.amount,
                isReceive: transaction.isReceive,
                txHash: transaction.txHash
            )
        )
    }
}

extension DefaultAccountPresenter: Web3ServiceWalletListener {
    
    func notificationsChanged() { updateView() }
}
