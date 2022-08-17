// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol AccountInteractor: AnyObject {
    func currency() -> Currency
    func market() -> Market?
    func candles() -> [Candle]?
    func cryptoBalance() -> BigInt
    func fiatBalance() -> Double
}

final class DefaultAccountInteractor {
    private let wallet: Wallet
    private let _currency: Currency
    private let networksService: NetworksService
    private let walletService: WalletService
    private let currencyStoreService: CurrencyStoreService
    private let currencyMetadataService: CurrencyMetadataService

    init(
        wallet: Wallet,
        currency: Currency,
        networksService: NetworksService,
        walletService: WalletService,
        currencyStoreService: CurrencyStoreService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.wallet = wallet
        self._currency = currency
        self.networksService = networksService
        self.walletService = walletService
        self.currencyService = currencyService
        self.currencyMetadataService = currencyMetadataService
    }
}

extension DefaultAccountInteractor: AccountInteractor {

    func currency() -> Currency {
        self._currency
    }

    func market() -> Market? {
        return currencyMetadataService.market(currency: _currency)
    }

    func candles() -> [Candle]? {
        currencyMetadataService.cachedCandles(currency: _currency)
    }

    func cryptoBalance() -> BigInt {
        let count = walletsStateService.transactionCount(wallet: wallet)
        return walletsStateService.balance(wallet: wallet, currency: _currency)
    }

    func fiatBalance() -> Double {
        let price = currencyMetadataService
                .market(currency: _currency)?
                .currentPrice?
                .doubleValue ?? 0
        let amount = _currency.double(balance: cryptoBalance())
        return price * amount
    }
}
