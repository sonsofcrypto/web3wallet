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
    
    func isValid(address: String, forNetwork network: Web3Network) -> Bool
    
    func update(network: Web3Network, active: Bool)
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String
}

enum Web3NetworkFee: String {
    
    case low
    case medium
    case high
}

struct Web3Network: Codable, Equatable, Hashable {
    
    let id: String
    let name: String
    let cost: String
    let hasDns: Bool
    let url: URL?
    let status: Status
    let connectionType: ConnectionType?
    let explorer: Explorer?
    let selectedByUser: Bool
}

extension Web3Network {
    
    enum Status: Codable, Equatable, Hashable {
        
        case unknown
        case connected
        case connectedSync(pct: Float)
        case disconnected
        case comingSoon
    }

    enum ConnectionType: Codable, Equatable, Hashable {
        
        case liteClient
        case networkDefault
        case infura
        case alchyme
    }
    
    enum Explorer: Codable, Equatable, Hashable {
        
        case liteClientOnly
        case web2
    }
}


extension Array where Element == Web3Network {
    
    var sortByName: [Web3Network] {
        
        sorted { $0.name < $1.name }
    }
}

struct Web3Token: Codable, Equatable {
    
    let symbol: String // ETH
    let name: String // Ethereum
    let address: String // 0x482828...
    let decimals: Int // 8
    let type: `Type`
    let network: Web3Network //
    let balance: Double
    let showInWallet: Bool
    let usdPrice: Double
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
    
    var usdBalance: Double {
        
        balance * usdPrice
    }
    
    var usdBalanceString: String {
        
        usdBalance.formatCurrency() ?? ""
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
                return $0.usdBalance > $1.usdBalance
                
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

    var networks: [Web3Network] {
        
        reduce([]) { result, token in
            
            if !result.contains(token.network) {
                
                var result = result
                result.append(token.network)
                return result
            }
            
            return result
        }
    }
}
