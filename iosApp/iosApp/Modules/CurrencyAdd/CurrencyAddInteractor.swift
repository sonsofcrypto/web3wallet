// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

// MARK: - CurrencyAddInteractorNewToken

struct CurrencyAddInteractorNewCurrency {
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
}

// MARK: - CurrencyAddInteractor

protocol CurrencyAddInteractor: AnyObject {
    func addCurrency(
        _ currency: CurrencyAddInteractorNewCurrency,
        for network: Network,
        onCompletion: @escaping () -> Void
    )
}

// MARK: - DefaultTokenAddInteractor

final class DefaultTokenAddInteractor {
    private let currencyStoreService: CurrencyStoreService

    init(currencyStoreService: CurrencyStoreService) {
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultTokenAddInteractor: CurrencyAddInteractor {
    
    func addCurrency(
        _ currency: CurrencyAddInteractorNewCurrency,
        for network: Network,
        onCompletion: @escaping () -> Void
    ) {
        let currency = Currency(
            name: currency.name,
            symbol: currency.symbol.lowercased(),
            decimals: KotlinUInt(value: UInt32(currency.decimals)),
            type: .erc20,
            address: currency.address,
            coinGeckoId: nil
        )
        currencyStoreService.add(currency: currency, network: network)
        onCompletion()
    }
}
