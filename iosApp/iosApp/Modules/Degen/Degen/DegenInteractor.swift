// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol DegenInteractor: AnyObject {

    var categoriesActive: [DAppCategory] { get }
    var categoriesInactive: [DAppCategory] { get }
}

final class DefaultDegenInteractor {


    private var degenService: DegenService

    init(_ degenService: DegenService) {
        
        self.degenService = degenService
    }
}

extension DefaultDegenInteractor: DegenInteractor {

    var categoriesActive: [DAppCategory] {
        
        degenService.categoriesActive
    }

    var categoriesInactive: [DAppCategory] {
        
        degenService.categoriesInactive
    }
}
