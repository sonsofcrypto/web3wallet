// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DashboardViewModel {
    let shouldAnimateCardSwitcher: Bool
    let header: DashboardViewModel.Header
    let sections: [DashboardViewModel.Section]
}

// MARK: - Header

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

// MARK: - Section

extension DashboardViewModel {

    struct Section {
        let name: String
        let wallets: [DashboardViewModel.Wallet]
        let nfts: [DashboardViewModel.NFT]
    }
}

// MARK: - Wallet

extension DashboardViewModel {

    struct Wallet {
        let name: String
        let ticker: String
        let imageName: String
        let fiatBalance: String
        let cryptoBalance: String
        let pctChange: String
        let priceUp: Bool
        let candles: CandlesViewModel
    }
}

// MARK: - NFT

extension DashboardViewModel {

    struct NFT {
        let imageName: String
    }
}

// MARK: - Tokens accounts

extension DashboardViewModel {

    static func tokens(_ tokens: [Token]) -> [DashboardViewModel.Wallet] {
        return tokens.enumerated().map {
            .init(
                name: $0.1.name,
                ticker: $0.1.ticker,
                imageName: $0.1.iconName,
                fiatBalance: $0.0 % 2 == 0 ? "$69,000" : "$42,000",
                cryptoBalance: ($0.0 % 2 == 0 ? "420.00" : "690.00") + " " + $0.1.ticker,
                pctChange: $0.0 % 2 == 0 ? "4.5%" : "2.5%",
                priceUp: true,
                candles: CandlesViewModel.mock(first: $0.0 % 2 == 0)
            )
        }
    }
}

// MARK: - Mock

extension DashboardViewModel {

    static func mockWalletsEHT() -> [DashboardViewModel.Wallet] {
        [
            .init(
                name: "Ethereum",
                ticker: "ETH",
                imageName: "token_eth_icon",
                fiatBalance: "$69,000",
                cryptoBalance: "420.00 ETH",
                pctChange: "4.5%",
                priceUp: true,
                candles: CandlesViewModel.mock()
            ),
            .init(
                name: "Curve",
                ticker: "CRV",
                imageName: "token_crv_icon",
                fiatBalance: "$42,000",
                cryptoBalance: "690.00 CRV",
                pctChange: "2.5%",
                priceUp: true,
                candles: CandlesViewModel.mock(first: false)
            )
        ]
    }

    static func mockWalletsSOL() -> [DashboardViewModel.Wallet] {
        [
            .init(
                name: "Solana",
                ticker: "SOL",
                imageName: "solana_sol_icon",
                fiatBalance: "$69,000",
                cryptoBalance: "420.00 SOL",
                pctChange: "12%",
                priceUp: true,
                candles: CandlesViewModel.mock(first: false)
            ),
            .init(
                name: "Raydium",
                ticker: "RAY",
                imageName: "token_ray_icon",
                fiatBalance: "$6,900.00",
                cryptoBalance: "4,200 RAY",
                pctChange: "5.5%",
                priceUp: true,
                candles: CandlesViewModel.mock()
            ),
            .init(
                name: "Mango",
                ticker: "MNGO",
                imageName: "token_mngo_icon",
                fiatBalance: "$4,200.00",
                cryptoBalance: "69 MNGO",
                pctChange: "5.5%",
                priceUp: true,
                candles: CandlesViewModel.mock(first: false)
            ),
            .init(
                name: "Solana",
                ticker: "SOL",
                imageName: "solana_sol_icon",
                fiatBalance: "$69,000",
                cryptoBalance: "420.00 SOL",
                pctChange: "12%",
                priceUp: true,
                candles: CandlesViewModel.mock(first: false)
            ),
            .init(
                name: "Raydium",
                ticker: "RAY",
                imageName: "token_ray_icon",
                fiatBalance: "$6,900.00",
                cryptoBalance: "4,200 RAY",
                pctChange: "5.5%",
                priceUp: true,
                candles: CandlesViewModel.mock()
            ),
            .init(
                name: "Mango",
                ticker: "MNGO",
                imageName: "token_mgno_icon",
                fiatBalance: "$4,200.00",
                cryptoBalance: "69 MNGO",
                pctChange: "5.5%",
                priceUp: true,
                candles: CandlesViewModel.mock(first: false)
            )
        ]
    }

    static func mockNFTsETH() -> [DashboardViewModel.NFT] {
        return [
            .init(imageName: "ape"),
            .init(imageName: "ape2"),
            .init(imageName: "ape3"),
            .init(imageName: "ape4"),
            .init(imageName: "ape5"),
            .init(imageName: "penguin"),
            .init(imageName: "penguin2"),
            .init(imageName: "punk"),
            .init(imageName: "punk2"),
            .init(imageName: "punk3"),
            .init(imageName: "punk4")
        ]
    }

    static func mockNFTsSOL() -> [DashboardViewModel.NFT] {
        return []
    }
}
