// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

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
    
    var accountWireframeContext: AccountWireframeContext? {
        switch type {
        case let .send(data):
            return .init(network: data.network, currency: data.currency)
        case let .swap(data):
            return .init(network: data.network, currency: data.currencyFrom)
        case .sendNFT, .cultCastVote, .approveUniswap:
            return nil
        }
    }
}

extension ConfirmationWireframeContext {
    
    struct SendContext {
        let network: Network
        let currency: Currency
        let amount: BigInt
        let addressFrom: String
        let addressTo: String
        let estimatedFee: Web3NetworkFee
    }
    
    struct SwapContext {
        let network: Network
        let provider: Provider
        let amountFrom: BigInt
        let amountTo: BigInt
        let currencyFrom: Currency
        let currencyTo: Currency
        let estimatedFee: Web3NetworkFee
        // NOTE: We inject here the service since this is not singleton and the instance in
        // CurrencySwap module will have all the correct info to execute the swap. In case
        // of an immediate error (which can happen straight away or in the future), we want
        // to display it in the confirmation screen, otherwise if its a future error, we will
        // display in the swap (as a toast), but if its a success, the Approving button in
        // this instance will just disapear (same as happens on Uniswap)
        let swapService: UniswapService
        
        struct Provider {
            let iconName: String
            let name: String
            let slippage: String
        }
    }
    
    struct SendNFTContext {
        let network: Network
        let addressFrom: String
        let addressTo: String
        let nftItem: NFTItem
        let estimatedFee: Web3NetworkFee
    }
    
    struct CultCastVoteContext {
        let cultProposal: CultProposal
        let approve: Bool
    }
    
    struct ApproveUniswapContext {
        let currency: Currency
        let onApproved: (((password: String, salt: String)) -> Void)
    }
}
