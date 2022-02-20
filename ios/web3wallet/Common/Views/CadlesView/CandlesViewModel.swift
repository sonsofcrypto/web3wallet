// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum CandlesViewModel {

    struct Candle {
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

// MARK: - Mock

extension CandlesViewModel {

    static func mock(_ count: Int = 34) -> CandlesViewModel {
        let candles: [CandlesViewModel.Candle] = (0..<count).map {
            candle(idx: $0, count: count)
        }
        return CandlesViewModel.loaded(candles)
    }

    static func candle(idx: Int, count: Int) -> CandlesViewModel.Candle {
        .init(
            open: CGFloat(idx * 1000),
            high: CGFloat(idx * 1000 + 1000),
            low: CGFloat(idx * 1000 - 500),
            close: CGFloat(idx * 1000 + 500),
            volume: CGFloat(100),
            period: Date().addingTimeInterval(TimeInterval(count - idx) - 60)
        )
    }
}