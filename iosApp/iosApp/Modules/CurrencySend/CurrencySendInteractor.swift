// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol CurrencySendInteractor: AnyObject {
    var walletAddress: String? { get }
    func defaultCurrency(network: Network) -> Currency
    func balance(currency: Currency, network: Network) -> BigInt
    func networkFees(network: Network) -> [NetworkFee]
}

final class DefaultCurrencySendInteractor {
    private let walletService: WalletService
    private let networksService: NetworksService
    
    init(
        walletService: WalletService,
        networksService: NetworksService
    ) {
        self.walletService = walletService
        self.networksService = networksService
    }
}

extension DefaultCurrencySendInteractor: CurrencySendInteractor {
    
    var walletAddress: String? {
        try? networksService.wallet()?.address().toHexStringAddress().hexString
    }
    
    func defaultCurrency(network: Network) -> Currency {
        walletService.currencies(network: network).first ?? network.nativeCurrency
    }
    
    func balance(currency: Currency, network: Network) -> BigInt {
        walletService.balance(network: network, currency: currency)
    }
    
    func networkFees(network: Network) -> [NetworkFee] {
        networksService.networkFees(network: network)
    }
}
