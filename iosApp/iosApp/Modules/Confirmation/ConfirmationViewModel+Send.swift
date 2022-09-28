// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension ConfirmationViewModel {
    
    struct SendViewModel {
        let currency: Currency
        let destination: Destination
        let estimatedFee: Fee
        
        struct Currency {
            let iconName: String
            let symbol: String
            let value: String
            let usdValue: String
        }
        
        struct Destination {
            let from: String
            let to: String
        }
        
        struct Fee {
            let value: String
            let usdValue: String
        }
    }
}
