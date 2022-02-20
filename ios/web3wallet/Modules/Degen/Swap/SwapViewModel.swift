// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SwapViewModel {
    let title: String
    let fromValueCrypto: String
    let fromValueFiat: String
    let fromTicker: String
    let fromBalance: String
    let fromCurrencyImage: String
    let toValueCrypto: String
    let toValueFiat: String
    let toTicker: String
    let toBalance: String
    let toCurrencyImage: String
    let rate: String
}

// MARK: - Utility

extension SwapViewModel {

    static func mock(_ title: String) -> SwapViewModel {
        .init(
            title: title,
            fromValueCrypto: "420.00",
            fromValueFiat: "$123,000",
            fromTicker: "ETH",
            fromBalance: "1000",
            fromCurrencyImage: "currency_icon_small_eth",
            toValueCrypto: "69,000.00",
            toValueFiat: "$123,000",
            toTicker: "SOL",
            toBalance: "0",
            toCurrencyImage: "currency_icon_small_sol",
            rate: "1 SOL = 0.000425 ETH"
        )
    }
}