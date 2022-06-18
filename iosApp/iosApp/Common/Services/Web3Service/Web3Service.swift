// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3ServiceWalletListener: AnyObject {
    
    func tokensChanged()
}

protocol Web3Service: AnyObject {

    var allNetworks: [Web3Network] { get }
    var allTokens: [Web3Token] { get }
    
    var myTokens: [Web3Token] { get }
    func storeMyTokens(to tokens: [Web3Token])
    
    func networkIcon(for network: Web3Network) -> Data
    func tokenIcon(for token: Web3Token) -> Data
    
    func addWalletListener(_ listener: Web3ServiceWalletListener)
    func removeWalletListener(_ listener: Web3ServiceWalletListener)
}

struct Web3Network: Codable, Equatable, Hashable {
    
    let name: String
    let hasDns: Bool
}

struct Web3Token: Codable, Equatable {
    
    let symbol: String
    let name: String
    let address: String
    let type: `Type`
    let network: Web3Network
    let balance: Double
    let showInWallet: Bool    
}

extension Web3Token {
    
    enum `Type`: Codable, Equatable {
        
        case normal
        case featured
        case popular
    }
}

extension Web3Token {
    
    func equalTo(network: String, symbol: String) -> Bool {
        
        self.network.name == network && self.symbol == symbol
    }
}

extension Array where Element == Web3Token {
    
    var sortByNetworkBalanceAndName: [Web3Token] {
        
        sorted {
            
            if $0.network.name != $1.network.name {
                
                return $0.network.name < $1.network.name
            } else if
                $0.network.name == $1.network.name &&
                $0.balance != $1.balance
            {
                return $0.balance > $1.balance
                
            } else {
                return $0.name < $1.name
            }
        }
    }
    
    var sortByNetworkAndName: [ Web3Token ] {
        
        sorted {
            
            guard $0.symbol == $1.symbol else {
                
                return $0.symbol < $0.symbol
            }
            
            return $0.network.name > $1.network.name
        }
    }

}
