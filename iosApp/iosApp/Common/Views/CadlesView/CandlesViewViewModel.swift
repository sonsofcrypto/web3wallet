// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum CandlesViewModel {

    struct Candle: Codable {
        let open: CGFloat
        let high: CGFloat
        let low: CGFloat
        let close: CGFloat
        let volume: CGFloat
        let period: Date
    }

    case unavailable(_ cnt: Int)
    case loading(_ cnt: Int)
    case loaded(_ candles: [Candle])
}

// MARK: - Utilities

extension CandlesViewModel {

    func isLoading() -> Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}
