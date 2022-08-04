// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct ConfirmationViewModel {
    
    let title: String
    let content: Content
    
    enum Content {
        
        case swap(SwapViewModel)
        case send(SendViewModel)
        case sendNFT(SendNFTViewModel)
    }
}
