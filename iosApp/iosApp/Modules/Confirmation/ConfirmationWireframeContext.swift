// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

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
        let estimatedFee: Web3NetworkFee
        
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
        let estimatedFee: Web3NetworkFee
        
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
    
    struct SendNFTContext {
        
        let nftItem: NFTItem
        let destination: Destination
        let estimatedFee: Web3NetworkFee
                
        struct Destination {
            
            let from: String
            let to: String
        }
    }
}
