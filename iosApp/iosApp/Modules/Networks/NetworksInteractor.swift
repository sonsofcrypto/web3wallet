// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NetworksInteractor: AnyObject {

    func networkIcon(for network: Web3Network) -> Data
    func allNetworks() -> [Web3Network]
    func update(network: Web3Network, active: Bool)
}

final class DefaultNetworksInteractor {

    private var networksService: NetworksService

    init(_ networksService: NetworksService) {
        
        self.networksService = networksService
    }
}

extension DefaultNetworksInteractor: NetworksInteractor {
    
    func networkIcon(for network: Web3Network) -> Data {
        
        networksService.networkIcon(for: network)
    }

    func allNetworks() -> [Web3Network] {
        
        networksService.allNetworks()
    }
    
    func update(network: Web3Network, active: Bool) {
        
        networksService.update(network: network, active: active)
    }

}
