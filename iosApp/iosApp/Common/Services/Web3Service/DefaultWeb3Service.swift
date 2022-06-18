// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DefaultWeb3Service {
    
    let web3ServiceLocalStorage: Web3ServiceLocalStorage
    
    init(
        web3ServiceLocalStorage: Web3ServiceLocalStorage
    ) {
        
        self.web3ServiceLocalStorage = web3ServiceLocalStorage
    }
}

extension DefaultWeb3Service: Web3Service {
    
    var allNetworks: [Web3Network] {
        [
            ethereumNetwork,
            solanaNetwork
        ]
    }
    
    var allTokens: [Web3Token] {
        
        var tokens = [Web3Token]()
        
        tokens.append(contentsOf: ethereumTokens)
        tokens.append(contentsOf: solanaTokens)
        
        return tokens.sortByNetworkAndName
    }
    
    var myTokens: [Web3Token] {
        
        let myTokens = web3ServiceLocalStorage.readMyTokens()
        
        guard myTokens.isEmpty else { return myTokens }
        
        return defaultTokens.sortByNetworkAndName
    }
    
    func storeMyTokens(to tokens: [Web3Token]) {
        
        web3ServiceLocalStorage.storeMyTokens(to: tokens)
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        
        switch network.name {
            
        case "Bitcoin":
            return "token_btc_icon".loadIconData
            
        case "Ethereum":
            return "token_eth_icon".loadIconData
            
        case "Solana":
            return "token_sol_icon".loadIconData
            
        default:
            
            return "default_token".loadIconData
        }
    }

    func tokenIcon(for token: Web3Token) -> Data {
        
        "token_\(token.symbol.lowercased())_icon".loadIconData
    }    
}

private extension DefaultWeb3Service {
    
    var defaultTokens: [Web3Token] {
        
        [
            ethereumEthToken,
            ethereumCultToken,
            ethereumUsdcToken,
            ethereumDotToken,
            solanaSolToken,
            solanaMngoToken
        ]
    }
}

private extension DefaultWeb3Service {
    
    var ethereumNetwork: Web3Network {
        
        .init(
            name: "Ethereum",
            hasDns: true
        )
    }
    
    var ethereumEthToken: Web3Token {
        
        .init(
            symbol: "ETH",
            name: "Ethereum",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .popular,
            network: ethereumNetwork,
            balance: 0
        )
    }
    
    var ethereumUsdcToken: Web3Token {
        
        .init(
            symbol: "USDC",
            name: "USD Coin",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .popular,
            network: ethereumNetwork,
            balance: 0
        )
    }
    
    var ethereumCultToken: Web3Token {
        
        .init(
            symbol: "CULT",
            name: "Cult DAO",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .featured,
            network: ethereumNetwork,
            balance: 0
        )
    }
    
    var ethereumDotToken: Web3Token {
        
        .init(
            symbol: "DOT",
            name: "Polkadot",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .normal,
            network: ethereumNetwork,
            balance: 0
        )
    }
    
    var ethereumTokens: [ Web3Token ] {
       
        [
            ethereumCultToken,
            ethereumUsdcToken,
            .init(
                symbol: "USDT",
                name: "Tether",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "DOGE",
                name: "Dogecoin",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "SHIB",
                name: "Shiba Inu",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            ethereumEthToken,
            .init(
                symbol: "SOL",
                name: "Solana",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "ADA",
                name: "Cardano",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "XRP",
                name: "XRP",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            ethereumDotToken,
            .init(
                symbol: "BNB",
                name: "BNB",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "MNGO",
                name: "Mango",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "CRV",
                name: "Curve DAO",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            ),
            .init(
                symbol: "RAY",
                name: "Raydium",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork,
                balance: 0
            )
        ]
    }
}

private extension DefaultWeb3Service {
    
   var solanaNetwork: Web3Network {
        
        .init(
            name: "Solana",
            hasDns: false
        )
    }
    
    var solanaSolToken: Web3Token {
        
        .init(
            symbol: "SOL",
            name: "Solana",
            address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
            type: .normal,
            network: solanaNetwork,
            balance: 0
        )
    }
    
    var solanaMngoToken: Web3Token {
        
        .init(
            symbol: "MNGO",
            name: "Mango",
            address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
            type: .normal,
            network: solanaNetwork,
            balance: 0
        )
    }
    
    var solanaTokens: [ Web3Token ] {
        
        [
            solanaSolToken,
            .init(
                symbol: "CRV",
                name: "Curve DAO",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: solanaNetwork,
                balance: 0
            ),
            solanaMngoToken,
            .init(
                symbol: "RAY",
                name: "Raydium",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: solanaNetwork,
                balance: 0
            )
        ]
    }
}

private extension Array where Element == Web3Token {
    
    var sortByNetworkAndName: [ Web3Token ] {
        
        sorted {
            
            guard $0.symbol == $1.symbol else {
                
                return $0.symbol < $0.symbol
            }
            
            return $0.network.name > $1.network.name
        }
    }
}
