// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

struct ConfirmationWireframeContext {
    let type: `Type`
    
    enum `Type` {
        case swap(SwapContext)
        case send(SendContext)
        case sendNFT(SendNFTContext)
        case cultCastVote(CultCastVoteContext)
        case approveUniswap(ApproveUniswapContext)
        
        var localizedTag: String {
            switch self {
            case .swap: return "swap"
            case .send: return "send"
            case .sendNFT: return "sendNFT"
            case .cultCastVote: return "cultCastVote"
            case .approveUniswap: return "approveUniswap"
            }
        }
    }
    
    var token: Web3Token? {
        switch type {
        case let .send(data):
            return data.token.token
        case let .swap(data):
            return data.tokenFrom.token
        case .sendNFT, .cultCastVote, .approveUniswap:
            // TODO: Annon to confirm where to push (main network token)? Eg: ETH
            return nil
        }
    }
}

extension ConfirmationWireframeContext {
    
    struct CurrencyData {
        let iconName: String
        let token: Web3Token
        let value: BigInt
    }
    
    struct AddressData {
        let from: String
        let to: String
    }
}

extension ConfirmationWireframeContext {
    
    struct SwapContext {
        let tokenFrom: CurrencyData
        let tokenTo: CurrencyData
        let provider: Provider
        let estimatedFee: Web3NetworkFee
        let swapService: UniswapService
        
        struct Provider {
            let iconName: String
            let name: String
            let slippage: String
        }
    }
    
    struct SendContext {
        let token: CurrencyData
        let destination: AddressData
        let estimatedFee: Web3NetworkFee
    }
    
    struct SendNFTContext {
        let nftItem: NFTItem
        let destination: AddressData
        let estimatedFee: Web3NetworkFee
    }
    
    struct CultCastVoteContext {
        let cultProposal: CultProposal
        let approve: Bool
    }
    
    struct ApproveUniswapContext {
        let iconName: String
        let token: Web3Token
        let onApproved: (((password: String, salt: String)) -> Void)
    }
}
