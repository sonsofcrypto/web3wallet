// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DefaultWeb3Service {
    
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
        
        tokens.append(contentsOf: bitcoinTokens)
        tokens.append(contentsOf: ethereumTokens)
        tokens.append(contentsOf: solanaTokens)
        
        return tokens.sorted {
            
            guard $0.network.name == $1.network.name else {
                
                return $0.symbol < $0.symbol
            }
            
            return $0.network.name < $1.network.name
        }
    }
    
    var myTokens: [Web3Token] {
        []
    }

}


private extension DefaultWeb3Service {
    
   var bitcoinNetwork: Web3Network {
        
        .init(
            icon: UIImage(named: "currency_icon_small_eth")!.pngData()!,
            name: "Bitcoin",
            hasDns: false
        )
    }
    
    var bitcoinTokens: [ Web3Token ] {
        
        [
            .init(
                image: UIImage(named: "currency_icon_small_eth")!.pngData()!,
                symbol: "BTC",
                name: "Bitcoin",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: bitcoinNetwork
            )
        ]
    }
}

private extension DefaultWeb3Service {
    
    var ethereumNetwork: Web3Network {
        
        .init(
            icon: UIImage(named: "currency_icon_small_eth")!.pngData()!,
            name: "Ethereum",
            hasDns: true
        )
    }
    
    var ethereumTokens: [ Web3Token ] {
       
        [
            .init(
                image: UIImage(named: "currency_icon_small_cult")?.pngData(),
                symbol: "CULT",
                name: "Cult DAO",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .featured,
                network: ethereumNetwork
            ),
            .init(
                image: nil,
                symbol: "USDC",
                name: "USD Coin",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .popular,
                network: ethereumNetwork
            ),
            .init(
                image: nil,
                symbol: "Tether",
                name: "USDT",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: nil,
                symbol: "DOGE",
                name: "Dogecoin",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: nil,
                symbol: "SHIB",
                name: "Shiba Inu",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: UIImage(named: "currency_icon_small_eth")!.pngData()!,
                symbol: "ETH",
                name: "Ethereum",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .popular,
                network: ethereumNetwork
            ),
            .init(
                image: UIImage(named: "currency_icon_small_crv")!.pngData()!,
                symbol: "CRV",
                name: "Curve DAO",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: UIImage(named: "currency_icon_small_mngo")!.pngData()!,
                symbol: "MNGO",
                name: "Mango",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: UIImage(named: "currency_icon_small_ray")!.pngData()!,
                symbol: "RAY",
                name: "Raydium",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                type: .normal,
                network: ethereumNetwork
            ),
            .init(
                image: UIImage(named: "currency_icon_small_sol")!.pngData()!,
                symbol: "SOL",
                name: "Solana",
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
            icon: UIImage(named: "currency_icon_small_sol")!.pngData()!,
            name: "Solana",
            hasDns: false
        )
    }
    
    var solanaTokens: [ Web3Token ] {
        
        [
            .init(
                image: UIImage(named: "currency_icon_small_sol")!.pngData()!,
                symbol: "SOL",
                name: "Solana",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                type: .normal,
                network: solanaNetwork
            )
        ]
    }
}
