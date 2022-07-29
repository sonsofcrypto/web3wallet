// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol Web3ServiceWalletListener: AnyObject {

    func nftsChanged()
    func notificationsChanged()
    func tokensChanged()
}

protocol Web3ServiceLegacy: AnyObject {

    var allNetworks: [Web3Network] { get }
    var allTokens: [Web3Token] { get }
    var myTokens: [Web3Token] { get }
    
    func storeMyTokens(to tokens: [Web3Token])
    
    func networkIcon(for network: Web3Network) -> Data
    func networkIconName(for network: Web3Network) -> String
    func tokenIcon(for token: Web3Token) -> Data
    func tokenIconName(for token: Web3Token) -> String
    
    func addWalletListener(_ listener: Web3ServiceWalletListener)
    func removeWalletListener(_ listener: Web3ServiceWalletListener)
    
    func isValid(address: String, forNetwork network: Web3Network) -> Bool
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String
    
    func update(network: Web3Network, active: Bool)
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String
    
    var currentEthBlock: String { get }
    
    func setNotificationAsDone(
        notificationId: String
    )
    var dashboardNotifications: [Web3Notification] { get }
    
    func nftsChanged()
}

enum Web3NetworkFee: String {
    
    case low
    case medium
    case high
}

struct Web3Network: Equatable, Hashable {
    
    let id: String
    let name: String
    let cost: String
    let hasDns: Bool
    let url: URL?
    let status: Status
    let connectionType: ConnectionType?
    let explorer: Explorer?
    let selectedByUser: Bool
    let chainId: UInt
    let networkType: Network.Type_
}

extension Web3Network {
    
    static func from(_ network: web3lib.Network, isOn: Bool) -> Web3Network {
        return .init(
            id: network.id(),
            name: network.name,
            cost: "",
            hasDns: false,
            url: nil,
            status: .connected,
            connectionType: .pocket,
            explorer: nil,
            selectedByUser: isOn,
            chainId: UInt(network.chainId),
            networkType: network.type
        )
    }

    func toNetwork() -> web3lib.Network {
        return web3lib.Network(
            name: name,
            chainId: UInt32(chainId),
            type: networkType,
            nameServiceAddress: nil
        )
    }
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
        case pocket
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

struct Web3Token: Equatable {
    let symbol: String // ETH
    let name: String // Ethereum
    let address: String // 0x482828...
    let decimals: Int // 8
    let type: `Type`
    let network: Web3Network //
    let balance: Double
    let showInWallet: Bool
    let usdPrice: Double
    let coingGeckoId: String?
}

extension Web3Token {
    
    enum `Type`: Codable, Equatable {
        
        case normal
        case featured
        case popular
    }
}

extension Web3Token {
    
    func equalTo(networkId: String, symbol: String) -> Bool {
        
        self.network.id == network.id && self.symbol == symbol
    }
    
    var usdBalance: Double {
        
        balance * usdPrice
    }
    
    var usdBalanceString: String {
        
        usdBalance.formatCurrency() ?? ""
    }
}

extension Web3Token {

    static func from(
        currency: Currency,
        network: Web3Network,
        inWallet: Bool
    ) -> Web3Token {
        return Web3Token(
            symbol: currency.symbol,
            name: currency.name,
            address: currency.address ?? "",
            decimals: Int(currency.decimals),
            type: .normal,
            network: network,
            balance: 0.0,
            showInWallet: inWallet,
            usdPrice: 0.0,
            coingGeckoId: currency.coinGeckoId
        )
    }

    func toCurrency() -> Currency {
        return Currency(
            name: name,
            symbol: symbol,
            decimals: UInt32(decimals),
            type: name == "Ethereum" ? .native : .erc20,
            address: address,
            coinGeckoId: coingGeckoId
        )
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

struct Web3Notification: Codable, Equatable {
    
    let id: String
    let image: Data // Security, Social, etc
    let title: String
    let body: String
    let deepLink: String
    let canDismiss: Bool
    let order: Int // 1, 2, 3, 4...(left to right)
}
