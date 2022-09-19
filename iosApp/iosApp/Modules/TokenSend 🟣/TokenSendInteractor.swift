// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol TokenSendInteractor: AnyObject {
    var walletAddress: String? { get }
    func defaultCurrency(network: Network) -> Currency
    func balance(currency: Currency, network: Network) -> BigInt
    func networkFees(network: Network) -> [Web3NetworkFee]
    func networkFeeInUSD(network: Network, fee: Web3NetworkFee) -> BigInt
    func networkFeeInSeconds(network: Network, fee: Web3NetworkFee) -> Int
    func networkFeeInNetworkToken(network: Network, fee: Web3NetworkFee) -> String
}

final class DefaultTokenSendInteractor {
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

extension DefaultTokenSendInteractor: TokenSendInteractor {
    
    var walletAddress: String? {
        try? networksService.wallet()?.address().toHexStringAddress().hexString
    }
    
    func defaultCurrency(network: Network) -> Currency {
        walletService.currencies(network: network).first ?? network.nativeCurrency
    }
    
    func balance(currency: Currency, network: Network) -> BigInt {
        walletService.balance(network: network, currency: currency)
    }
    
    func networkFees(network: Network) -> [Web3NetworkFee] {
        [.low, .medium, .high]
    }

    func networkFeeInUSD(network: Network, fee: Web3NetworkFee) -> BigInt {
        // TODO: Connect Fee
        .zero
    }
    
    func networkFeeInSeconds(network: Network, fee: Web3NetworkFee) -> Int {
        // TODO: Connect Fee
        1
    }

    func networkFeeInNetworkToken(network: Network, fee: Web3NetworkFee) -> String {
        // TODO: Connect Fee
        "🤷🏻‍♂️"
    }
}
