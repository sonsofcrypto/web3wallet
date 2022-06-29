// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AccountInteractor: AnyObject {

    func priceData(for token: Web3Token) -> [ Web3Candle ]
}

final class DefaultAccountInteractor {

    private let priceHistoryService: PriceHistoryService


    init(
        priceHistoryService: PriceHistoryService
    ) {
        self.priceHistoryService = priceHistoryService
    }
}

extension DefaultAccountInteractor: AccountInteractor {
    
    func priceData(for token: Web3Token) -> [ Web3Candle ] {
        
        priceHistoryService.priceData(for: token, period: .lastXDays(34))
    }

}
