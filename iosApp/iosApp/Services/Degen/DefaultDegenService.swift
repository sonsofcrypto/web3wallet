// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultDegenService {

}

extension DefaultDegenService: DegenService {

    var categoriesActive: [DAppCategory] {
        
        DAppCategory.active
    }
    
    var categoriesInactive: [DAppCategory] {
        
        DAppCategory.inactive
    }
}
