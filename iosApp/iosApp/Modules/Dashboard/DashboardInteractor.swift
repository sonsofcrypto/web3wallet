// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol DashboardInteractor: AnyObject {

    var allNetworks: [Web3Network] { get }
    var myTokens: [Web3Token] { get }
    func tokenIcon(for token: Web3Token) -> Data
    func priceData(for token: Web3Token) -> [ Web3Candle ]
    func nfts(for network: Web3Network) -> [ NFTItem ]
    func updateMyWeb3Tokens(to tokens: [Web3Token])
    func addWalletListener(_ listener: Web3ServiceWalletListener)
    func removeWalletListener(_ listener: Web3ServiceWalletListener)
}

final class DefaultDashboardInteractor {

    private let web3Service: Web3Service
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService

    init(
        web3Service: Web3Service,
        priceHistoryService: PriceHistoryService,
        nftsService: NFTsService
    ) {
        
        self.web3Service = web3Service
        self.priceHistoryService = priceHistoryService
        self.nftsService = nftsService
    }
}

extension DefaultDashboardInteractor: DashboardInteractor {
    
    var allNetworks: [Web3Network] {
        
        web3Service.allNetworks
    }

    var myTokens: [Web3Token] {
        
        web3Service.myTokens
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        
        web3Service.tokenIcon(for: token)
    }
    
    func priceData(for token: Web3Token) -> [ Web3Candle ] {
        
        priceHistoryService.priceData(for: token, period: .lastXDays(43))
    }
    
    func nfts(for network: Web3Network) -> [ NFTItem ] {
        
        nftsService.yourNFTs(forNetwork: network)
    }
    
    func updateMyWeb3Tokens(to tokens: [Web3Token]) {
        
        web3Service.storeMyTokens(to: tokens)
    }
    
    func addWalletListener(_ listener: Web3ServiceWalletListener) {
        
        web3Service.addWalletListener(listener)
    }
    
    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
        
        web3Service.removeWalletListener(listener)
    }

}
