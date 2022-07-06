// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenSendViewModel {
    
    let title: String
    let items: [Item]
}

extension TokenSendViewModel {
    
    enum Item {
        
        case address(Address)
        case token(Token)
    }
    
    struct Address {
        
        let value: String?
        let isValid: Bool
    }
    
    struct Token {
        
        let tokenAmount: Double?
        let tokenSymbol: String
    }
}

extension Array where Element == TokenSendViewModel.Item {
    
    var address: TokenSendViewModel.Address? {
        
        var address: TokenSendViewModel.Address?
        forEach {
            
            if case let TokenSendViewModel.Item.address(value) = $0 {
                
                address = value
            }
        }
        
        return address
    }
    
    var token: TokenSendViewModel.Token? {
        
        var token: TokenSendViewModel.Token?
        forEach {
            
            if case let TokenSendViewModel.Item.token(value) = $0 {
                
                token = value
            }
        }
        
        return token
    }
}
