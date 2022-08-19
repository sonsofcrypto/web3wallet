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
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    // TODD(Anon): Refactor to shared formatters
    private let fiatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        return formatter
    }()
    // TODD(Anon): Refactor to shared formatters
    private let largeFiatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = false
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    // TODD(Anon): Refactor to shared formatters
    private let pctFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    // TODD(Anon): Refactor to shared formatters
    private let currencyFormatter = CurrencyFormatter()

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
        let cryptoBalance = interactor.cryptoBalance()
        let fiatBalance = interactor.fiatBalance()
        let formattedCrypto = currencyFormatter.format(
            bigInt: cryptoBalance,
            currency: currency
        )
        let formattedFiat = fiatFormatter.string(from: fiatBalance as NSNumber) ?? "-"
        let formattedPct = pctFormatter.string(from: Float(truncating: market?.priceChangePercentage24h ?? 0) / 100.0) 
        return .init(
            currencyName: currency.name,
            header: .init(
                balance: formattedCrypto + currency.symbol,
                fiatBalance: formattedFiat,
                pct: formattedPct,
                pctUp: true,
                buttons: headerButtonViewModels()
            ),
            candles: .loaded(CandlesViewModel.Candle.from(interactor.candles()?.last(n: 90))),
            marketInfo: .init(
                marketCap: largeFiatFormatter.string(from: market?.marketCap ?? 0) ?? "-",
                price: fiatFormatter.string(from: market?.currentPrice ?? 0) ?? "-",
                volume: largeFiatFormatter.string(from: market?.totalVolume ?? 0) ?? "-"
            ),
            bonusAction: currency.symbol == "cult" ? .init(title: "Read the manifesto") : nil,
            transactions: interactor.transactions().map {
                transactionViewModel($0)
            }
        )
    }

    func headerButtonViewModels() -> [AccountViewModel.Header.Button] {
        [
            .init(title: Localized("receive"), imageName: "receive-button".themeImage),
            .init(title: Localized("send"), imageName: "send-button".themeImage),
            .init(title: Localized("swap"), imageName: "swap-button".themeImage),
            .init(title: Localized("more"), imageName: "more-button".themeImage)
        ]
    }

    func transactionViewModel(
        _ transaction: AccountInteractorTransaction
    ) -> AccountViewModel.Transaction {
         AccountViewModel.Transaction(
            date: dateFormatter.string(from: transaction.date),
            address: transaction.address,
            amount: transaction.amount,
            isReceive: transaction.isReceive
        )
    }

    func updateView() {
        view?.update(with: viewModel())
    }
}
