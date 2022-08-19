// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol AccountInteractor: AnyObject {
    func address() -> String
    func currency() -> Currency
    func metadata() -> CurrencyMetadata?
    func market() -> CurrencyMarketData?
    func candles() -> [Candle]?
    func cryptoBalance() -> BigInt
    func fiatBalance() -> Double
    func transactions() -> [AccountInteractorTransaction]
    func fetchTransactions(_ handler: @escaping ([EtherscanTransaction]) -> ())
}

struct AccountInteractorTransaction {
    let date: Date
    let address: String
    let amount: String
    let isReceive: Bool
}

final class DefaultAccountInteractor {
    private let wallet: Wallet
    private let network: Network
    private let _currency: Currency
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let transactionService: EtherscanService

    init(
        wallet: Wallet,
        currency: Currency,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        transactionService: EtherscanService
    ) {
        self.wallet = wallet
        self.network = wallet.network() ?? Network.ethereum()
        self._currency = currency
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.transactionService = transactionService
    }
}

extension DefaultAccountInteractor: AccountInteractor {

    func address() -> String {
        walletService.address(network: network) ?? ""
    }

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

    func transactions() -> [AccountInteractorTransaction] {
        guard let address = walletService.address(network: network) else {
            return []
        }
        // TODO: - Parse amount from Transaction.Input
        // TODO: - Filter by currency
        return transactionService.cachedTransactionHistory(
            for: address,
            nonce: walletService.blockNumber(network: network).toDecimalString()
        ).map {
            let isReceive = $0.to == self.address()
            return .init(
                date: Date(timeIntervalSince1970: (try? $0.timeStamp.double()) ?? 0),
                address: isReceive ? $0.from : $0.to,
                amount: $0.value,
                isReceive: isReceive
            )
        }
    }

    func fetchTransactions(_ handler: @escaping ([EtherscanTransaction]) -> ()) {
        guard let address = walletService.address(network: network) else { return }
        transactionService.fetchTransactionHistory(for: address) { result in
            switch result {
            case let .success(transactions):
                handler(transactions)
            case let .failure(error):
                print(error)
                handler([])
            }
        }
    }
}
