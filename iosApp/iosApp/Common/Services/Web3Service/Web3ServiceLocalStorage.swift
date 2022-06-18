// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Web3ServiceLocalStorage: AnyObject {
    
    func readMyTokens() -> [Web3Token]
    func storeMyTokens(to tokens: [Web3Token])
}

final class DefaultWeb3ServiceLocalStorage {
    
    let userDefaultsKey = "my-tokens"
    let userDefaults = UserDefaults.standard
}

extension DefaultWeb3ServiceLocalStorage: Web3ServiceLocalStorage {
    
    func readMyTokens() -> [Web3Token] {
        
        guard let data = userDefaults.object(forKey: userDefaultsKey) as? Data else {
            return []
        }
        return (try? JSONDecoder().decode([Web3Token].self, from: data)) ?? []
    }
    
    func storeMyTokens(to tokens: [Web3Token]) {
        
        guard let data = try? JSONEncoder().encode(tokens) else { return }
        userDefaults.set(data, forKey: userDefaultsKey)
    }
}
