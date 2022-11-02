// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol NFTSendInteractor: AnyObject {
    var walletAddress: String? { get }
    func networkFees(network: Network) -> [NetworkFee]
    func fiatPrice(currency: Currency) -> Double
}

final class DefaultNFTSendInteractor {
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    init(
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultNFTSendInteractor: NFTSendInteractor {
    
    var walletAddress: String? {
        try? networksService.wallet()?.address().toHexStringAddress().hexString
    }
    
    func networkFees(network: Network) -> [NetworkFee] {
        networksService.networkFees(network: network)
    }
    
    func fiatPrice(currency: Currency) -> Double {
        currencyStoreService.marketData(currency: currency)?.currentPrice?.doubleValue ?? 0
    }
}
