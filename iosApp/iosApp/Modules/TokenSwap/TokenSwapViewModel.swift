// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenSwapViewModel {
    
    let title: String
    let items: [Item]
}

extension TokenSwapViewModel {
    
    enum Item {
        
        case swap(Swap)
        case limit
    }
    
    struct Swap {
        
        let tokenFrom: TokenEnterAmountViewModel
        let tokenTo: TokenEnterAmountViewModel
        let tokenSwapProviderViewModel: TokenSwapProviderViewModel
        let tokenSwapPriceViewModel: TokenSwapPriceViewModel
        let tokenSwapSlippageViewModel: TokenSwapSlippageViewModel
        let tokenNetworkFeeViewModel: TokenNetworkFeeViewModel
        let buttonState: State

        enum State {
            
            case swap(providerIcon: Data)
            case insufficientFunds
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
}
