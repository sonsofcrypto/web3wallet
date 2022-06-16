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
            bitcoinNetwork,
            ethereumNetwork,
            solanaNetwork
        ]
    }
    
    var allTokens: [Web3Token] {
        
        var tokens = [Web3Token]()
        
        tokens.append(bitcoinToken)
        tokens.append(contentsOf: ethereumTokens)
        tokens.append(contentsOf: solanaTokens)
        
        return tokens.sortByNetworkAndName
    }
    
    var myTokens: [Web3Token] {
        
        let myTokens = web3ServiceLocalStorage.getMyTokens()
        
        guard myTokens.isEmpty else { return myTokens }
        
        return defaultTokens.sortByNetworkAndName
    }

}

private extension DefaultWeb3Service {
    
    var defaultTokens: [Web3Token] {
        
        [
            bitcoinToken,
            ethereumEthToken,
            ethereumUsdcToken,
            ethereumCultToken,
            solanaSolToken
        ]
    }
}

private extension DefaultWeb3Service {
    
   var bitcoinNetwork: Web3Network {
        
        .init(
            icon: "token_btc_icon".loadIconData,
            name: "Bitcoin",
            hasDns: false
        )
    }
    
    var bitcoinToken: Web3Token {
        
        .init(
            image: "token_btc_icon".loadIconData,
            symbol: "BTC",
            name: "Bitcoin",
            address: "691tAaz5x1HUXrCNLbtMDqcw6o5Sdn4xqX",
            type: .normal,
            network: bitcoinNetwork
        )
    }
}

private extension DefaultWeb3Service {
    
    var ethereumNetwork: Web3Network {
        
        .init(
            icon: "token_eth_icon".loadIconData,
            name: "Ethereum",
            hasDns: true
        )
    }
    
    var ethereumEthToken: Web3Token {
        
        .init(
            image: "token_eth_icon".loadIconData,
            symbol: "ETH",
            name: "Ethereum",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .popular,
            network: ethereumNetwork
        )
    }
    
    var ethereumUsdcToken: Web3Token {
        
        .init(
            image: "token_usdc_icon".loadIconData,
            symbol: "USDC",
            name: "USD Coin",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .popular,
            network: ethereumNetwork
        )
    }
    
    var ethereumCultToken: Web3Token {
        
        .init(
            image: "token_cult_icon".loadIconData,
            symbol: "CULT",
            name: "Cult DAO",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            type: .featured,
            network: ethereumNetwork
        )
    }
    
    var ethereumTokens: [ Web3Token ] {
       
        [
            ethereumCultToken,
            ethereumUsdcToken,
            .init(
                image: "token_usdt_icon".loadIconData,
                symbol: "Tether",
                name: "USDT",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_doge_icon".loadIconData,
                symbol: "DOGE",
                name: "Dogecoin",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_shib_icon".loadIconData,
                symbol: "SHIB",
                name: "Shiba Inu",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            ethereumEthToken,
            .init(
                image: "token_sol_icon".loadIconData,
                symbol: "SOL",
                name: "Solana",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_ada_icon".loadIconData,
                symbol: "ADA",
                name: "Cardano",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_xrp_icon".loadIconData,
                symbol: "XRP",
                name: "XRP",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_dot_icon".loadIconData,
                symbol: "DOT",
                name: "Polkadot",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_bnb_icon".loadIconData,
                symbol: "BNB",
                name: "BNB",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_mngo_icon".loadIconData,
                symbol: "MNGO",
                name: "Mango",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_crv_icon".loadIconData,
                symbol: "CRV",
                name: "Curve DAO",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: "token_ray_icon".loadIconData,
                symbol: "RAY",
                name: "Raydium",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            )
        ]
    }
}

private extension DefaultWeb3Service {
    
   var solanaNetwork: Web3Network {
        
        .init(
            icon: "token_sol_icon".loadIconData,
            name: "Solana",
            hasDns: false
        )
    }
    
    var solanaSolToken: Web3Token {
        
        .init(
            image: "token_sol_icon".loadIconData,
            symbol: "SOL",
            name: "Solana",
            address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
            type: .normal,
            network: solanaNetwork
        )
    }
    
    var solanaTokens: [ Web3Token ] {
        
        [
            solanaSolToken,
            .init(
                image: "token_crv_icon".loadIconData,
                symbol: "CRV",
                name: "Curve DAO",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: solanaNetwork
            ),
            .init(
                image: "token_mngo_icon".loadIconData,
                symbol: "MNGO",
                name: "Mango",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: solanaNetwork
            ),
            .init(
                image: "token_ray_icon".loadIconData,
                symbol: "RAY",
                name: "Raydium",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: solanaNetwork
            )
        ]
    }
}

private extension Array where Element == Web3Token {
    
    var sortByNetworkAndName: [ Web3Token ] {
        
        sorted {
            
            guard $0.network.name == $1.network.name else {
                
                return $0.symbol < $0.symbol
            }
            
            return $0.network.name < $1.network.name
        }
    }
}
