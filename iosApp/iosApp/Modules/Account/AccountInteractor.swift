// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol AccountInteractor: AnyObject {
    func currency() -> Currency
    func metadata() -> CurrencyMetadata?
    func market() -> CurrencyMarketData?
    func candles() -> [Candle]?
    func cryptoBalance() -> BigInt
    func fiatBalance() -> Double
}

final class DefaultAccountInteractor {
    private let wallet: Wallet
    private let network: Network
    private let _currency: Currency
    private let networksService: NetworksService
    private let walletService: WalletService
    private let currencyStoreService: CurrencyStoreService

    init(
        wallet: Wallet,
        currency: Currency,
        networksService: NetworksService,
        walletService: WalletService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.wallet = wallet
        self.network = wallet.network() ?? Network.ethereum()
        self._currency = currency
        self.networksService = networksService
        self.walletService = walletService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultAccountInteractor: AccountInteractor {

    func currency() -> Currency {
        self._currency
    }

    func metadata() -> CurrencyMetadata? {
        currencyStoreService.metadata(currency: _currency)
    }

    func market() -> CurrencyMarketData? {
        currencyStoreService.marketData(currency: _currency)
    }

    func candles() -> [Candle]? {
        currencyStoreService.candles(currency: _currency)
    }

    func cryptoBalance() -> BigInt {
        walletService.balance(network: network, currency: _currency)
    }

    func fiatBalance() -> Double {
        let price = currencyStoreService.marketData(currency: _currency)?
            .currentPrice?
            .doubleValue ?? 0
        return CurrencyFormatter.Companion().crypto(
            amount: cryptoBalance(),
            decimals: _currency.decimals(),
            mul: price
        )
    }
}
