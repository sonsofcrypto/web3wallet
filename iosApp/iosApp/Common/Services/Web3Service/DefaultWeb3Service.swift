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
    
    var allTokens: [Web3Token] {
        
        web3ServiceLocalStorage.readAllTokens().sortByNetworkAndName
    }
    
    var myTokens: [Web3Token] {
        
        web3ServiceLocalStorage.readMyTokens().sortByNetworkBalanceAndName
    }
    
    func storeMyTokens(to tokens: [Web3Token]) {
        
        web3ServiceLocalStorage.storeMyTokens(with: tokens)
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
    
    func addWalletListener(_ listener: Web3ServiceWalletListener) {
        
        web3ServiceLocalStorage.addWalletListener(listener)
    }
    
    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
        
        web3ServiceLocalStorage.removeWalletListener(listener)
    }
    
    func isValid(address: String, forNetwork network: Web3Network) -> Bool {
        
        switch network.name.lowercased() {
            
        case "ethereum":
            return address.hasPrefix("0x") && address.count == 42
            
        case "solana":
            return true
            
        default:
            return false
        }
    }
}
