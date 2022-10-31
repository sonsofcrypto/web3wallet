// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol NFTSendInteractor: AnyObject {
    var walletAddress: String? { get }
    func networkFees(network: Network) -> [NetworkFee]
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
    
    func networkFees(network: Network) -> [NetworkFee] {
        networksService.networkFees(network: network)
    }
}
