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
                    iconName: "token_eth_icon"
                ),
                .init(
                    name: "CULT",
                    ticker: "CULT",
                    address: nil,
                    network: .ethereum,
                    iconName: "token_cult_icon"
                )
            ]
        case .solana:
            return [
                .init(
                    name: "Solana",
                    ticker: "SOL",
                    address: nil,
                    network: .solana,
                    iconName: "solana_sol_icon"
                ),
                .init(
                    name: "Raydium",
                    ticker: "RAY",
                    address: nil,
                    network: .solana,
                    iconName: "token_ray_icon"
                ),
                .init(
                    name: "Mango",
                    ticker: "MNGO",
                    address: nil,
                    network: .solana,
                    iconName: "token_mngo_icon"
                ),
                .init(
                    name: "Solana",
                    ticker: "SOL",
                    address: nil,
                    network: .solana,
                    iconName: "solana_sol_icon"
                ),
                .init(
                    name: "Raydium",
                    ticker: "RAY",
                    address: nil,
                    network: .solana,
                    iconName: "token_ray_icon"
                ),
                .init(
                    name: "Mango",
                    ticker: "MNGO",
                    address: nil,
                    network: .solana,
                    iconName: "token_mngo_icon"
                )
            ]
        }
    }
}
