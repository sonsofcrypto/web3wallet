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
        let cryptoBalance = interactor.cryptoBalance()
        let fiatBalance = interactor.fiatBalance()
        let formattedCrypto = currencyFormatter.format(
            bigInt: cryptoBalance,
            currency: currency
        )
        let formattedFiat = fiatFormatter.string(from: fiatBalance as NSNumber) ?? "-"
        let formattedPct = pctFormatter.string(from: Float(market?.priceChangePercentage24h ?? 0) / 100.0) ?? "-"
        let tmp = largeFiatFormatter.string(from: market?.marketCap ?? 0) ?? "-"
        return .init(
            currencyName: currency.name,
            header: .init(
                balance: formattedCrypto + currency.symbol,
                fiatBalance: formattedFiat,
                pct: formattedPct,
                pctUp: true,
                buttons: makeButtons()
            ),
            candles: .loaded(CandlesViewModel.Candle.from(interactor.candles()?.last(n: 90))),
            marketInfo: .init(
                marketCap: largeFiatFormatter.string(from: market?.marketCap ?? 0) ?? "-",
                price: fiatFormatter.string(from: market?.currentPrice ?? 0) ?? "-",
                volume: largeFiatFormatter.string(from: market?.totalVolume ?? 0) ?? "-"
            ),
            bonusAction: currency.symbol == "CULT" ? .init(title: "Read the manifesto") : nil,
            transactions: [
//                .init(
//                    date: "23 Feb 2022",
//                    address: "0xcf6fa3373c3ed7e0c2f502e39be74fd4d6f054ee",
//                    amount: "+ 6.90 " + token.symbol,
//                    isReceive: true
//                ),
//                .init(
//                    date: "14 Jan 2022",
//                    address: "0xcf6fa3373c3ed7e0c2f502e39be74fd4d6f054ee",
//                    amount: "- 4.20 " + token.symbol,
//                    isReceive: false
//                )
            ]
        )
    }
}

private extension DefaultAccountPresenter {
    
    func makeButtons() -> [CustomVerticalButton.ViewModel] {
        [
            .init(
                title: Localized("receive"),
                imageName: "receive-button".themeImage,
                onTap: makeOnReceieveTap()
            ),
            .init(
                title: Localized("send"),
                imageName: "send-button".themeImage,
                onTap: makeOnSendTap()
            ),
            .init(
                title: Localized("swap"),
                imageName: "swap-button".themeImage,
                onTap: makeOnSwapTap()
            ),
            .init(
                title: Localized("more"),
                imageName: "more-button".themeImage,
                onTap: makeOnMoreTap()
            )
        ]
    }
    
    func makeOnReceieveTap() -> () -> Void {
        
        {
            [weak self] in
            
            guard let self = self else { return }
            
            self.handle(.receive)
        }
    }
    
    func makeOnSendTap() -> () -> Void {
        
        {
            [weak self] in
            
            guard let self = self else { return }
            
            self.handle(.send)
        }
    }
    
    func makeOnSwapTap() -> () -> Void {
        
        {
            [weak self] in
            
            guard let self = self else { return }
            
            self.handle(.swap)
        }
    }
    
    func makeOnMoreTap() -> () -> Void {
        
        {
            [weak self] in
            
            guard let self = self else { return }
            
            self.handle(.more)
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
