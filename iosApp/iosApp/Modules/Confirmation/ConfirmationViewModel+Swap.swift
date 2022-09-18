// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension ConfirmationViewModel {
    
    struct SwapViewModel {
        let tokenFrom: Token
        let tokenTo: Token
        let provider: Provider
        let estimatedFee: Fee
        
        struct Token {
            let iconName: String
            let symbol: String
            let value: String
            let usdValue: String
        }
        
        struct Provider {
            let iconName: String
            let name: String
            let slippage: String
        }
        
        struct Fee {
            let value: String
            let usdValue: String
        }
    }
}
