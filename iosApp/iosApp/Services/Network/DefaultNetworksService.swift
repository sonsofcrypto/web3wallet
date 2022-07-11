// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultNetworksService {
    
    let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultNetworksService: NetworksService {
    
    func networkIcon(for network: Web3Network) -> Data {
        
        web3Service.networkIcon(for: network)
    }
    
    func allNetworks() -> [Web3Network] {
        
        web3Service.allNetworks
    }
    
    func update(network: Web3Network, active: Bool) {
        
        web3Service.update(network: network, active: active)
    }
}
