// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3ServiceLocalStorage: AnyObject {
    
    func readAllTokens() -> [Web3Token]
    func storeAllTokens(with tokens: [Web3Token])
    
    func readMyTokens() -> [Web3Token]
    func storeMyTokens(with tokens: [Web3Token])
    
    func addWalletListener(_ listener: Web3ServiceWalletListener)
    func removeWalletListener(_ listener: Web3ServiceWalletListener)
    
    func update(network: Web3Network, active: Bool)
}

final class DefaultWeb3ServiceLocalStorage {
    
    private let allTokensKey = "all-tokens"
    private let userDefaults = UserDefaults.standard
    
    private var listeners: [Web3ServiceWalletListener] = []
}

extension DefaultWeb3ServiceLocalStorage: Web3ServiceLocalStorage {
    
    func readAllTokens() -> [Web3Token] {
        
        let allTokens = loadAllTokens()
        
        guard allTokens.isEmpty else { return allTokens }

        var tokens = [Web3Token]()
        tokens.append(contentsOf: ethereumTokens)
        tokens.append(contentsOf: solanaTokens)
        
        storeAllTokens(with: tokens)
        
        return tokens
    }
    
    func storeAllTokens(with tokens: [Web3Token]) {
        
        guard let data = try? JSONEncoder().encode(tokens) else { return }
        userDefaults.set(data, forKey: allTokensKey)
        
        updateListenersWalletTokensChanged()
    }
    
    func readMyTokens() -> [Web3Token] {
        
        let allTokens = readAllTokens()
        return allTokens.filter { $0.showInWallet && $0.network.selectedByUser }
    }
    
    func storeMyTokens(with myTokens: [Web3Token]) {
        
        let allTokens = readAllTokens()
        
        var newTokens = [Web3Token]()
        
        allTokens.forEach { token in
            
            if let myToken = myTokens.first(where: { $0.equalTo(network: token.network.name, symbol: token.symbol) }) {
                newTokens.append(
                    .init(
                        symbol: myToken.symbol,
                        name: myToken.name,
                        address: myToken.address,
                        decimals: myToken.decimals,
                        type: myToken.type,
                        network: myToken.network,
                        balance: myToken.balance,
                        showInWallet: true,
                        usdPrice: myToken.usdPrice
                    )
                )
            } else {
                newTokens.append(
                    .init(
                        symbol: token.symbol,
                        name: token.name,
                        address: token.address,
                        decimals: token.decimals,
                        type: token.type,
                        network: token.network,
                        balance: token.balance,
                        showInWallet: false,
                        usdPrice: token.usdPrice
                    )
                )
            }
        }
        
        storeAllTokens(with: newTokens)
    }
    
    func addWalletListener(_ listener: Web3ServiceWalletListener) {
        
        guard !listeners.contains(where: { $0 === listener}) else { return }
        
        listeners.append(listener)
    }
    
    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
        
        listeners.removeAll { $0 === listener }
    }
    
    func update(network: Web3Network, active: Bool) {
        
        let tokens = readAllTokens()
        
        var updatedTokens = [Web3Token]()
        tokens.forEach {
            
            if $0.network.name == network.name {
                
                updatedTokens.append(
                    .init(
                        symbol: $0.symbol,
                        name: $0.name,
                        address: $0.address,
                        decimals: $0.decimals,
                        type: $0.type,
                        network: .init(
                            id: $0.network.id,
                            name: $0.network.name,
                            hasDns: $0.network.hasDns,
                            url: $0.network.url,
                            status: $0.network.status,
                            connectionType: $0.network.connectionType,
                            explorer: $0.network.explorer,
                            selectedByUser: active
                        ),
                        balance: $0.balance,
                        showInWallet: $0.showInWallet,
                        usdPrice: $0.usdPrice
                    )
                )
            } else {
                
                updatedTokens.append($0)
            }
        }
        storeAllTokens(with: updatedTokens)
        
        updateListenersWalletTokensChanged()
    }
}

private extension DefaultWeb3ServiceLocalStorage {
    
    func loadAllTokens() -> [Web3Token] {
        
        guard let data = userDefaults.object(forKey: allTokensKey) as? Data else {
            return []
        }
        return (try? JSONDecoder().decode([Web3Token].self, from: data)) ?? []
    }
    
    func updateListenersWalletTokensChanged() {
        
        listeners.forEach { $0.tokensChanged() }
    }
}

private extension DefaultWeb3ServiceLocalStorage {
    
    var ethereumNetwork: Web3Network {
        
        .init(
            id: "60",
            name: "Ethereum",
            hasDns: true,
            url: nil,
            status: .connected,
            connectionType: .liteClient,
            explorer: .liteClientOnly,
            selectedByUser: true
        )
    }
    
    var ethereumEthToken: Web3Token {
        
        .init(
            symbol: "ETH",
            name: "Ethereum",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            decimals: 4,
            type: .popular,
            network: ethereumNetwork,
            balance: 0,
            showInWallet: true,
            usdPrice: 1008.77
        )
    }
    
    var ethereumUsdcToken: Web3Token {
        
        .init(
            symbol: "USDC",
            name: "USD Coin",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            decimals: 2,
            type: .popular,
            network: ethereumNetwork,
            balance: 0,
            showInWallet: true,
            usdPrice: 1.00
            
        )
    }
    
    var ethereumCultToken: Web3Token {
        
        .init(
            symbol: "CULT",
            name: "Cult DAO",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            decimals: 0,
            type: .featured,
            network: ethereumNetwork,
            balance: 0,
            showInWallet: true,
            usdPrice: 0.00000902
        )
    }
    
    var ethereumDotToken: Web3Token {
        
        .init(
            symbol: "DOT",
            name: "Polkadot",
            address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
            decimals: 2,
            type: .normal,
            network: ethereumNetwork,
            balance: 0,
            showInWallet: true,
            usdPrice: 7.92
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
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 1.00
            ),
            .init(
                symbol: "DOGE",
                name: "Dogecoin",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.054510
            ),
            .init(
                symbol: "SHIB",
                name: "Shiba Inu",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 0,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.00000791
            ),
            ethereumEthToken,
            .init(
                symbol: "SOL",
                name: "Solana",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 30.25
            ),
            .init(
                symbol: "ADA",
                name: "Cardano",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.46
            ),
            .init(
                symbol: "XRP",
                name: "XRP",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.309679
            ),
            ethereumDotToken,
            .init(
                symbol: "BNB",
                name: "BNB",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 202.32
            ),
            .init(
                symbol: "MNGO",
                name: "Mango",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.04704166
            ),
            .init(
                symbol: "CRV",
                name: "Curve DAO",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.595908
            ),
            .init(
                symbol: "RAY",
                name: "Raydium",
                address: "0x71C7632EC7ab88b098ddfB731B7401B5f6d8976F",
                decimals: 2,
                type: .normal,
                network: ethereumNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.628254
            )
        ]
    }
}

private extension DefaultWeb3ServiceLocalStorage {
    
   var solanaNetwork: Web3Network {
        
        .init(
            id: "90",
            name: "Solana",
            hasDns: false,
            url: nil,
            status: .disconnected,
            connectionType: .networkDefault,
            explorer: .web2,
            selectedByUser: true
        )
    }
    
    var solanaSolToken: Web3Token {
        
        .init(
            symbol: "SOL",
            name: "Solana",
            address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
            decimals: 2,
            type: .normal,
            network: solanaNetwork,
            balance: 0,
            showInWallet: true,
            usdPrice: 30.25
        )
    }
    
    var solanaMngoToken: Web3Token {
        
        .init(
            symbol: "MNGO",
            name: "Mango",
            address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
            decimals: 2,
            type: .normal,
            network: solanaNetwork,
            balance: 0,
            showInWallet: true,
            usdPrice: 0.04704166
        )
    }
    
    var solanaTokens: [ Web3Token ] {
        
        [
            solanaSolToken,
            .init(
                symbol: "CRV",
                name: "Curve DAO",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                decimals: 2,
                type: .normal,
                network: solanaNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.595908
            ),
            solanaMngoToken,
            .init(
                symbol: "RAY",
                name: "Raydium",
                address: "HN7cABqLq46Es1jh92dQQisAq662SmxEJKLsHHe4YWrH",
                decimals: 2,
                type: .normal,
                network: solanaNetwork,
                balance: 0,
                showInWallet: false,
                usdPrice: 0.628254
            )
        ]
    }
}
