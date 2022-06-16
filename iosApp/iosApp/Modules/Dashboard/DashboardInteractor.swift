// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol DashboardInteractor: AnyObject {

    var myTokens: [Web3Token] { get }
    func tokenIcon(for token: Web3Token) -> Data
    func priceData(for token: Web3Token) -> [ Web3Candle ]
}

final class DefaultDashboardInteractor {

    private let web3Service: Web3Service
    private let priceHistoryService: PriceHistoryService

    init(
        web3Service: Web3Service,
        priceHistoryService: PriceHistoryService
    ) {
        
        self.web3Service = web3Service
        self.priceHistoryService = priceHistoryService
    }
}

extension DefaultDashboardInteractor: DashboardInteractor {

    var myTokens: [Web3Token] {
        
        web3Service.myTokens
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        
        web3Service.tokenIcon(for: token)
    }
    
    func priceData(for token: Web3Token) -> [ Web3Candle ] {
        
        priceHistoryService.priceData(for: token, period: .lastXDays(43))
    }
}
