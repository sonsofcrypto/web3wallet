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

// MARK: - Mock

extension CandlesViewModel {

    static func mock(_ count: Int = 34, first: Bool = true) -> CandlesViewModel {
        
        guard let url = Bundle.main.url(forResource: "mock-candles", withExtension: "json") else {
            fatalError("mockCadle.json not found")
        }
        
        struct CandleMock: Codable {
            let open: String
            let high: String
            let low: String
            let close: String
            let volume: String
            let period: Date
        }
        
        do {
            let data = try Data(contentsOf: url)
            let candles = try JSONDecoder().decode([CandleMock].self, from: data)
            let result = candles.map {
                CandlesViewModel.Candle(
                    open: CGFloat(try! $0.open.double()),
                    high: CGFloat(try! $0.high.double()),
                    low: CGFloat(try! $0.low.double()),
                    close: CGFloat(try! $0.close.double()),
                    volume: CGFloat(try! $0.volume.double()),
                    period: $0.period
                )
            }
            return CandlesViewModel.loaded(
                first ? result.first(n: count) : result.last(n: count)
            )
        } catch {
            print(error)
        }
        
        return CandlesViewModel.unavailable(0)    }

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
