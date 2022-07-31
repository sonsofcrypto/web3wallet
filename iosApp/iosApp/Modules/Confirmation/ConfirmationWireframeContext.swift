//
//  ConfirmationWireframeContext.swift
//  iosApp
//
//  Created by web3 on 20/07/2022.
//

import Foundation

struct ConfirmationWireframeContext {
    
    let type: `Type`
    let onSuccessHandler: () -> Void
    
    enum `Type` {
        case swap(SwapContext)
        case send(SendContext)
        
        var accountToken: Web3Token {
            
            switch self {
                
            case let .swap(swapData):
                return swapData.tokenFrom.token
                
            case let .send(sendData):
                return sendData.token.token
            }
        }
    }
}

extension ConfirmationWireframeContext {
    
    struct SwapContext {
        
        let tokenFrom: Token
        let tokenTo: Token
        let provider: Provider
        let estimatedFee: Double // in the token from unit
        
        struct Token {
            
            let iconName: String
            let token: Web3Token
            let value: Double
        }
        
        struct Provider {
            
            let iconName: String
            let name: String
            let slippage: String
        }
    }
    
    struct SendContext {
        
        let token: Token
        let destination: Destination
        let estimatedFee: Double // in the token from unit
        
        struct Token {
            
            let iconName: String
            let token: Web3Token
            let value: Double
        }
        
        struct Destination {
            
            let from: String
            let to: String
        }
    }
}
