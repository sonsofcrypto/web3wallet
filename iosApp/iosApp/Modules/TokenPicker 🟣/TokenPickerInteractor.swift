// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol TokenPickerInteractor: AnyObject {
    var selectedNetwork: Network? { get }
    var supportedNetworks: [Network] { get }
    func myCurrencies(for network: Network) -> [Currency]
    func currencies(filteredBy searchTerm: String, for network: Network) -> [Currency]
    func balance(for currency: Currency, network: Network) -> BigInt
}

final class DefaultTokenPickerInteractor {
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService

    init(
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultTokenPickerInteractor: TokenPickerInteractor {
    var selectedNetwork: Network? { networksService.network }
    
    var supportedNetworks: [Network] { networksService.enabledNetworks() }
    
    func myCurrencies(for network: Network) -> [Currency] {
        walletService.currencies(network: network)
    }
    
    func currencies(filteredBy searchTerm: String, for network: Network) -> [Currency] {
        searchTerm.isEmpty
            ? currencyStoreService.currencies(network: network, limit: 1000)
            : currencyStoreService.search(term: searchTerm, network: network, limit: 1000)
    }
    
    func balance(for currency: Currency, network: Network) -> BigInt {
        walletService.balance(network: network, currency: currency)
    }
}
