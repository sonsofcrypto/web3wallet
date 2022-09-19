// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

// MARK: - TokenAddInteractorNewToken

struct TokenAddInteractorNewToken {
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
}

// MARK: - TokenAddInteractor

protocol TokenAddInteractor: AnyObject {
    func addToken(
        _ newToken: TokenAddInteractorNewToken,
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

extension DefaultTokenAddInteractor: TokenAddInteractor {
    
    func addToken(
        _ newToken: TokenAddInteractorNewToken,
        for network: Network,
        onCompletion: @escaping () -> Void
    ) {
        let currency = Currency(
            name: newToken.name,
            symbol: newToken.symbol.lowercased(),
            decimals: KotlinUInt(value: UInt32(newToken.decimals)),
            type: .erc20,
            address: newToken.address,
            coinGeckoId: nil
        )
        currencyStoreService.add(currency: currency, network: network)
        onCompletion()
    }
}
