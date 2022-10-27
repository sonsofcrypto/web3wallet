// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

extension ConfirmationViewModel {
    
    struct SendNFTViewModel {
        let nftItem: NFTItem
        let destination: Destination
        let estimatedFee: Fee
                
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
