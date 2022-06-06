// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol DashboardInteractor: AnyObject {

    func tokens(for network: CryptoNetwork) -> [Token]
}

// MARK: - DefaultDashboardInteractor

final class DefaultDashboardInteractor {

    private var walletsService: KeyStoreService

    init(_ walletsService: KeyStoreService) {
        self.walletsService = walletsService
    }
}

// MARK: - DefaultDashboardInteractor

extension DefaultDashboardInteractor: DashboardInteractor {

    func tokens(for network: CryptoNetwork) -> [Token] {
        switch network {
        case .ethereum:
            return [
                .init(
                    name: "Ethereum",
                    ticker: "ETH",
                    address: nil,
                    network: .ethereum,
                    iconName: "currency_icon_small_eth"
                ),
                .init(
                    name: "CULT",
                    ticker: "CULT",
                    address: nil,
                    network: .ethereum,
                    iconName: "currency_icon_small_cult"
                )
            ]
        case .solana:
            return [
                .init(
                    name: "Solana",
                    ticker: "SOL",
                    address: nil,
                    network: .solana,
                    iconName: "currency_icon_small_sol"
                ),
                .init(
                    name: "Raydium",
                    ticker: "RAY",
                    address: nil,
                    network: .solana,
                    iconName: "currency_icon_small_ray"
                ),
                .init(
                    name: "Mango",
                    ticker: "MNGO",
                    address: nil,
                    network: .solana,
                    iconName: "currency_icon_small_mngo"
                ),
                .init(
                    name: "Solana",
                    ticker: "SOL",
                    address: nil,
                    network: .solana,
                    iconName: "currency_icon_small_sol"
                ),
                .init(
                    name: "Raydium",
                    ticker: "RAY",
                    address: nil,
                    network: .solana,
                    iconName: "currency_icon_small_ray"
                ),
                .init(
                    name: "Mango",
                    ticker: "MNGO",
                    address: nil,
                    network: .solana,
                    iconName: "currency_icon_small_mngo"
                )
            ]
        }
    }
}
