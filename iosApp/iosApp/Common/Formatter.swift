// Created by web3d3v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

class Formatter {

    static let fiat: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        return formatter
    }()

    static let pct: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    static let currency = CurrencyFormatter()
}
