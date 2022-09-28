// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol NFTSendInteractor: AnyObject {
    var walletAddress: String? { get }
    func networkFees(network: Network) -> [Web3NetworkFee]
    func networkFeeInUSD(network: Network, fee: Web3NetworkFee) -> BigInt
    func networkFeeInSeconds(network: Network, fee: Web3NetworkFee) -> Int
    func networkFeeInNetworkToken(network: Network, fee: Web3NetworkFee) -> String
}

final class DefaultNFTSendInteractor {
    private let networksService: NetworksService
    
    init(networksService: NetworksService) {
        self.networksService = networksService
    }
}

extension DefaultNFTSendInteractor: NFTSendInteractor {
    
    var walletAddress: String? {
        try? networksService.wallet()?.address().toHexStringAddress().hexString
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
