// Created by web3d4v on 16/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol PriceHistoryService: AnyObject {
    
    func priceData(for token: Web3Token, period: Web3Period) -> [ Web3Candle ]
}

enum Web3Period {
    
    case lastXDays(Int)
}

struct Web3Candle: Codable {
    
    let open: CGFloat
    let high: CGFloat
    let low: CGFloat
    let close: CGFloat
    let volume: CGFloat
    let period: Date
}

final class DefaultPriceHistoryService {
    
}

extension DefaultPriceHistoryService: PriceHistoryService {
    
    func priceData(for token: Web3Token, period: Web3Period) -> [ Web3Candle ] {
        
        switch period {
        case let .lastXDays(count):
            return mostRecentDayCandles(count: count, first: Bool.random())
        }
    }
}


private extension DefaultPriceHistoryService {
    
    struct CandleMock: Codable {
        let open: String
        let high: String
        let low: String
        let close: String
        let volume: String
        let period: Date
    }

    func mostRecentDayCandles(count: Int = 34, first: Bool = true) -> [Web3Candle] {
        
        guard let url = Bundle.main.url(forResource: "mock-candles", withExtension: "json") else {
            fatalError("mockCadle.json not found")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let candles = try JSONDecoder().decode([CandleMock].self, from: data)
            let result = candles.map {
                Web3Candle(
                    open: CGFloat(try! $0.open.double()),
                    high: CGFloat(try! $0.high.double()),
                    low: CGFloat(try! $0.low.double()),
                    close: CGFloat(try! $0.close.double()),
                    volume: CGFloat(try! $0.volume.double()),
                    period: $0.period
                )
            }
            return first ? result.first(n: count) : result.last(n: count)
        } catch (let error) {
            print(error)
            return []
        }
    }
}
