// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

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

extension CandlesViewModel.Candle {

    static func from(_ candle: web3lib.Candle) -> CandlesViewModel.Candle {
        CandlesViewModel.Candle(
            open: candle.open,
            high: candle.high,
            low: candle.low,
            close: candle.close,
            volume: 0,
            period: Date(timeIntervalSince1970:
                Double(Int(candle.timestamp.epochSeconds))
            )
        )

    }
}
