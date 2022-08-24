// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

final class DefaultDegenService {

    private let walletService: WalletService
    init(
        walletService: WalletService
    ) {
        self.walletService = walletService
    }
}

extension DefaultDegenService: DegenService {

    var categoriesActive: [DAppCategory] {
        
        guard let selectedNetwork = walletService.selectedNetwork() else {
            return DAppCategory.active(includingCult: false)
        }
        
        // TODO: @Annon check if we should filter this in a better way
        switch selectedNetwork.type {
        case .l1:
            return DAppCategory.active(includingCult: true)
        default:
            return DAppCategory.active(includingCult: false)
        }
    }
    
    var categoriesInactive: [DAppCategory] {
        
        DAppCategory.inactive
    }
}
