// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AccountInteractor: AnyObject {

    var wallet: KeyStoreItem { get }
    var token: Web3Token { get }
    func priceData(for token: Web3Token) -> [ Web3Candle ]
}

final class DefaultAccountInteractor {

    private let priceHistoryService: PriceHistoryService
    private (set) var wallet: KeyStoreItem
    private (set) var token: Web3Token


    init(
        priceHistoryService: PriceHistoryService,
        wallet: KeyStoreItem,
        token: Web3Token
    ) {
        self.priceHistoryService = priceHistoryService
        self.wallet = wallet
        self.token = token
    }
}

extension DefaultAccountInteractor: AccountInteractor {
    
    func priceData(for token: Web3Token) -> [ Web3Candle ] {
        
        priceHistoryService.priceData(for: token, period: .lastXDays(34))
    }

}
