// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct ConfirmationViewModel {
    let title: String
    let content: Content
    
    enum Content {
        case inProgress(TxInProgressViewModel)
        case success(TxSuccessViewModel)
        case failed(TxFailedViewModel)
        case swap(SwapViewModel)
        case send(SendViewModel)
        case sendNFT(SendNFTViewModel)
        case cultCastVote(CultCastVoteViewModel)
        case approveUniswap(ApproveUniswapViewModel)
    }
}

extension ConfirmationViewModel {
    
    struct TxInProgressViewModel {
        let title: String
        let message: String
    }
    
    struct TxSuccessViewModel {
        let title: String
        let message: String
        let cta: String
        let ctaSecondary: String
    }

    struct TxFailedViewModel {
        let title: String
        let error: String
        let cta: String
        let ctaSecondary: String
    }
}
