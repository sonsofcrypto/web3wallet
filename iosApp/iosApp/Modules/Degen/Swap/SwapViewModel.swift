// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SwapViewModel {
    let title: String
    let fromInput: SwapViewModel.Input
    let toInput: SwapViewModel.Input
    let rate: String
}

// MARK: - Input

extension SwapViewModel {

    struct Input {
        let valueCrypto: String
        let valueFiat: String
        let ticker: String
        let balance: String
        let currencyImage: String
    }
}

// MARK: - Utility

extension SwapViewModel {

    static func mock(_ title: String) -> SwapViewModel {
        .init(
            title: title,
            fromInput: .init(
                valueCrypto: "420.00",
                valueFiat: "$123,000",
                ticker: "ETH",
                balance: "1000",
                currencyImage: "token_eth_icon"
            ),
            toInput: .init(
                valueCrypto: "69,000.00",
                valueFiat: "$123,000",
                ticker: "SOL",
                balance: "0",
                currencyImage: "solana_sol_icon"
            ),
            rate: "1 SOL = 0.000425 ETH"
        )
    }
}
