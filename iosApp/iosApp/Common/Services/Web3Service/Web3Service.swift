// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3Service: AnyObject {

    var allNetworks: [Web3Network] { get }
    var allTokens: [Web3Token] { get }
    
    var myTokens: [Web3Token] { get }
    func storeMyTokens(to tokens: [Web3Token])
    
    func networkIcon(for network: Web3Network) -> Data
    func tokenIcon(for token: Web3Token) -> Data
}

struct Web3Network: Codable, Equatable, Hashable {
    
    let name: String
    let hasDns: Bool
}

struct Web3Token: Codable {
    
    let symbol: String
    let name: String
    let address: String
    let type: `Type`
    let network: Web3Network
    let balance: Double
}

extension Web3Token {
    
    enum `Type`: Codable {
        
        case normal
        case featured
        case popular
    }
}

extension Array where Element == Web3Token {
    
    var sortByNetworkBalanceAndName: [Web3Token] {
        
        sorted {
            
            if $0.network.name != $1.network.name {
                
                return $0.network.name < $1.network.name
            }
            else if $0.balance != $0.balance {
                
                return $0.balance < $1.balance
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
