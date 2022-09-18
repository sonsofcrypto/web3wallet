// Created by web3d4v on 03/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension ConfirmationViewModel {
    
    struct ApproveUniswapViewModel {
        let iconName: String
        let symbol: String
        let fee: Fee
        
        struct Fee {
            let value: String
            let usdValue: String
        }
    }
}
