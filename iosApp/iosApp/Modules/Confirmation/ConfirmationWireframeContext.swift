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
        case sendNFT(SendNFTContext)
    }
}

extension ConfirmationWireframeContext {
    
    struct SwapContext {
        
        let tokenFrom: Token
        let tokenTo: Token
        let provider: Provider
        let estimatedFee: Fee
        
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
        
        enum Fee {
            
            case low
            case medium
            case high
        }
    }
    
    struct SendContext {
        
        let token: Token
        let destination: Destination
        let estimatedFee: Fee
        
        struct Token {
            
            let iconName: String
            let token: Web3Token
            let value: Double
        }
        
        struct Destination {
            
            let from: String
            let to: String
        }
        
        enum Fee: String {
            
            case low
            case medium
            case high
        }
    }
    
    struct SendNFTContext {
        
        let nftItem: NFTItem
        let destination: Destination
        let estimatedFee: Fee
                
        struct Destination {
            
            let from: String
            let to: String
        }
        
        enum Fee {
            
            case low
            case medium
            case high
        }
    }
}
