// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

// MARK: - suffix number

extension Int {
    
    var stringValue: String {
        "\(self)"
    }

    var abbreviated: String {
        let abbrev = ["K", " mil", " bil", "T", "P", "E"]
        return abbrev.enumerated()
            .reversed()
            .reduce(nil as String?) { accum, tuple in
                let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
                let truncRemainder = factor.truncatingRemainder(dividingBy: 1)
                let format = truncRemainder == 0 ? "%.0f%@" : "%.1f%@"

                if let accum = accum {
                    return accum
                }

                if factor > 1 {
                    return String(format: format, factor, String(tuple.1))
                }

                return nil
            } ?? String(self)
    }
}

