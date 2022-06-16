// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3ServiceLocalStorage: AnyObject {
    
    func getMyTokens() -> [Web3Token]
    func add(token: Web3Token)
    func remove(token: Web3Token)
}

final class DefaultWeb3ServiceLocalStorage {
    
    let userDefaultsKey = "my-tokens"
    let userDefaults = UserDefaults.standard
}

extension DefaultWeb3ServiceLocalStorage: Web3ServiceLocalStorage {
    
    func add(token: Web3Token) {
        
        var tokens = getMyTokens()
        
        guard !tokens.contains (
            where: { $0.network.name == token.network.name && $0.symbol == token.symbol }
        ) else { return }
        
        tokens.append(token)
    }

    func remove(token: Web3Token) {
        
        var tokens = getMyTokens()
        
        tokens.removeAll {
            $0.network.name == token.network.name && $0.symbol == token.symbol
        }
        
        store(tokens: tokens)
    }

    func getMyTokens() -> [Web3Token] {
        
        guard let data = userDefaults.object(forKey: userDefaultsKey) as? Data else {
            return []
        }
        return (try? JSONDecoder().decode([Web3Token].self, from: data)) ?? []
    }
}

private extension DefaultWeb3ServiceLocalStorage {
    
    func store(tokens: [Web3Token]) {
        
        guard let data = try? JSONEncoder().encode(tokens) else { return }
        userDefaults.set(data, forKey: userDefaultsKey)
    }
}
