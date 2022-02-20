// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DashboardViewModel {
    let header: DashboardViewModel.Header
    let sections: [DashboardViewModel.Section]
}

// MARK: - Header

extension DashboardViewModel {

    struct Header {
        let balance: String
        let pct: String
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
//        let candles: [CandleViewModel]
    }
}

// MARK: - NFT

extension DashboardViewModel {

    struct NFT {
        let imageName: String
    }
}

// MARK: - Mock

extension DashboardViewModel {

    static func mockWalletsEHT() -> [DashboardViewModel.Wallet] {
        [
            .init(
                name: "Ethereum",
                ticker: "ETH",
                imageName: "currency_icon_small_eth",
                fiatBalance: "$69,000",
                cryptoBalance: "420.00 ETH",
                pctChange: "4.5%",
                priceUp: true
            ),
            .init(
                name: "Curve",
                ticker: "CRV",
                imageName: "currency_icon_small_crv",
                fiatBalance: "$42,000",
                cryptoBalance: "690.00 CRV",
                pctChange: "2.5%",
                priceUp: true
            )
        ]
    }

    static func mockNFTsETH() -> [DashboardViewModel.NFT] {
        return [
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
            .init(imageName: ""),
        ]
    }

    static func mockWalletsSOL() -> [DashboardViewModel.Wallet] {
        [
            .init(
                name: "Solana",
                ticker: "SOL",
                imageName: "currency_icon_small_sol",
                fiatBalance: "$69,000",
                cryptoBalance: "420.00 SOL",
                pctChange: "12%",
                priceUp: true
            ),
            .init(
                name: "Raydium",
                ticker: "RAY",
                imageName: "currency_icon_small_ray",
                fiatBalance: "$6,900.00",
                cryptoBalance: "4,200 RAY",
                pctChange: "5.5%",
                priceUp: true
            ),
            .init(
                name: "Mango",
                ticker: "MNGO",
                imageName: "currency_icon_small_mngo",
                fiatBalance: "$4,200.00",
                cryptoBalance: "69 MNGO",
                pctChange: "5.5%",
                priceUp: true
            )
        ]
    }

    static func mockNFTsSOL() -> [DashboardViewModel.NFT] {
        return []
    }
}