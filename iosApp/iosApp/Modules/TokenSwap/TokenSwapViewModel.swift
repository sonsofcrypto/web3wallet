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
        
        case token(Token)
        case send(Send)
    }
    
    struct Token {
        
        let tokenAmount: Double?
        let tokenSymbolIcon: Data
        let tokenSymbol: String
        let tokenMaxAmount: Double
        let tokenMaxDecimals: Int
        let currencyTokenPrice: Double
        let shouldUpdateTextFields: Bool
    }
    
    struct Send {
        
        let estimatedFee: String
        let feeType: FeeType
        let buttonState: State
        
        enum FeeType {
            
            case low
            case medium
            case high
        }
        
        enum State {
            
            case insufficientFunds
            case ready
        }
    }
}

extension Array where Element == TokenSwapViewModel.Item {
    
    var token: TokenSwapViewModel.Token? {
        
        var token: TokenSwapViewModel.Token?
        forEach {
            
            if case let TokenSwapViewModel.Item.token(value) = $0 {
                
                token = value
            }
        }
        
        return token
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
