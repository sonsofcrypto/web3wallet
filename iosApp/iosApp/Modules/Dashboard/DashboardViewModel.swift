// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DashboardViewModel {
    let shouldAnimateCardSwitcher: Bool
    let header: DashboardViewModel.Header
    let sections: [DashboardViewModel.Section]
}

extension DashboardViewModel {

    struct Header {
        let balance: String
        let pct: String
        let pctUp: Bool
        let buttons: [DashboardViewModel.Header.Button]
        let firstSection: String?

        struct Button {
            let title: String
            let imageName: String
        }
    }
}

extension DashboardViewModel {

    struct Section {
        let name: String
        let wallets: [DashboardViewModel.Wallet]
        let nfts: [DashboardViewModel.NFT]
    }
}

extension DashboardViewModel {

    struct Wallet {
        
        let name: String
        let ticker: String
        let imageData: Data
        let fiatBalance: String
        let cryptoBalance: String
        let pctChange: String
        let priceUp: Bool
        let candles: CandlesViewModel
    }
}

extension DashboardViewModel {

    struct NFT {
        let image: String
        let onSelected: () -> Void
    }
}
