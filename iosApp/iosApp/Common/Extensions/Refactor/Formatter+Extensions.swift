// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension NumberFormatter {

    static let pct: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.locale = .init(identifier: "en" )
        return formatter
    }()

    func string(from val: Float) -> String {
        self.string(from: NSNumber(value: val)) ?? "-"
    }
}
