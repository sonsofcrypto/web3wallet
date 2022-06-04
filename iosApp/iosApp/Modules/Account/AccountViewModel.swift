// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct AccountViewModel {

    let currencyName: String
    let header: AccountViewModel.Header
    let candles: CandlesViewModel
    let marketInfo: AccountViewModel.MarketInfo
    let bonusAction: AccountViewModel.BonusAction?
    let transactions: [AccountViewModel.Transaction]
}

extension AccountViewModel {

    struct Header {
        let balance: String
        let fiatBalance: String
        let pct: String
        let pctUp: Bool
        let buttons: [DashboardViewModel.Header.Button]

        struct Button {
            let title: String
            let imageName: String
        }
    }
}

extension AccountViewModel {

    struct MarketInfo {
        let marketCap: String
        let price: String
        let volume: String
    }
}

extension AccountViewModel {

    struct BonusAction {
        let title: String
    }
}

extension AccountViewModel {

    struct Transaction {
        let date: String
        let address: String
        let amount: String
        let isReceive: Bool
    }
}
