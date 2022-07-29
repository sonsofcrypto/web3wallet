// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NetworksInteractor: AnyObject {

    func networkIconName(for network: Web3Network) -> String
    func allNetworks() -> [Web3Network]
    func update(network: Web3Network, active: Bool)
}

final class DefaultNetworksInteractor {

    private var web3Service: Web3ServiceLegacy

    init(web3Service: Web3ServiceLegacy) {
        
        self.web3Service = web3Service
    }
}

extension DefaultNetworksInteractor: NetworksInteractor {
    
    func networkIconName(for network: Web3Network) -> String {
        
        web3Service.networkIconName(for: network)
    }

    func allNetworks() -> [Web3Network] {
        
        web3Service.allNetworks
    }
    
    func update(network: Web3Network, active: Bool) {
        
        web3Service.update(network: network, active: active)
    }

}
