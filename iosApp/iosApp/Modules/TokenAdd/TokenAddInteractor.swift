// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol TokenAddInteractor: AnyObject {

    var defaultNetwork: Web3Network { get }
    func isValid(address: String, forNetwork: Web3Network) -> Bool
}

final class DefaultTokenAddInteractor {

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenAddInteractor: TokenAddInteractor {

    var defaultNetwork: Web3Network {
        
        let network = web3Service.allTokens.networks.first {
            $0.name.lowercased() == "ethereum"
        }
        
        guard let network = network else { fatalError("Missing ethereum network!") }
        
        return network
    }
    
    func isValid(address: String, forNetwork network: Web3Network) -> Bool {
        
        web3Service.isValid(address: address, forNetwork: network)
    }
}
