//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

extension NumberFormatter {

    static let pct: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    func string(from val: Float) -> String {
        self.string(from: NSNumber(value: val)) ?? "-"
    }
}
