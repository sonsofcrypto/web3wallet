// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenAddInteractorNewToken {
    
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
}

protocol TokenAddInteractor: AnyObject {
    
    var defaultNetwork: Web3Network { get }
    func isValid(address: String, forNetwork: Web3Network) -> Bool
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String
    func addToken(
        _ newToken: TokenAddInteractorNewToken,
        onCompletion: @escaping () -> Void
    )
}

final class DefaultTokenAddInteractor {
    

    private let web3Service: Web3ServiceLegacy
    
    init(
        web3Service: Web3ServiceLegacy
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
    
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String {
        
        web3Service.addressFormattedShort(address: address, network: network)
    }
    
    func addToken(
        _ newToken: TokenAddInteractorNewToken,
        onCompletion: @escaping () -> Void
    ) {
        
        // TODO: @Annon to connect and add new token
        onCompletion()
    }

}
