// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenSwapViewModel {
    
    let title: String
    let items: [Item]
}

extension TokenSwapViewModel {
    
    struct Fee {
        
        let id: String
        let name: String
        let value: String
    }
    
    enum Item {
        
        case swap(Swap)
        case send(Send)
    }
    
    struct Swap {
        
        let tokenFrom: TokenSwapTokenViewModel
        let tokenTo: TokenSwapTokenViewModel
    }
    
    struct Send {
        
        let tokenSwapProviderViewModel: TokenSwapProviderViewModel
        let tokenNetworkFeeViewModel: TokenNetworkFeeViewModel
        let buttonState: State
        
        enum State {
            
            case insufficientFunds
            case ready
        }
    }
}

extension Array where Element == TokenSwapViewModel.Item {
    
    var swap: TokenSwapViewModel.Swap? {
        
        var swap: TokenSwapViewModel.Swap?
        forEach {
            
            if case let TokenSwapViewModel.Item.swap(value) = $0 {
                
                swap = value
            }
        }
        
        return swap
    }
    
    var send: TokenSwapViewModel.Send? {
        
        var send: TokenSwapViewModel.Send?
        forEach {
            
            if case let TokenSwapViewModel.Item.send(value) = $0 {
                
                send = value
            }
        }
        
        return send
    }
}
