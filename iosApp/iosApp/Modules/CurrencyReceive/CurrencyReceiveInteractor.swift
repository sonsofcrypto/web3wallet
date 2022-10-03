// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol CurrencyReceiveInteractor: AnyObject {
    func receivingAddress(network: Network, currency: Currency) -> String
}

final class DefaultCurrencyReceiveInteractor {
    private let networksService: NetworksService
    
    init(networksService: NetworksService) {
        self.networksService = networksService
    }
}

extension DefaultCurrencyReceiveInteractor: CurrencyReceiveInteractor {

    func receivingAddress(network: Network, currency: Currency) -> String {
        // TODO: Review this in the future when currencies may have its own receiving address
        // for now this is not an issue though.
        guard let address = try? networksService.wallet(network: network)?.address() else {
            fatalError("Unable to read wallet address from network \(network.name)")
        }
        return address.toHexStringAddress().hexString
    }
}
