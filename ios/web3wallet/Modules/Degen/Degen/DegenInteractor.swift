//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol DegenInteractor: AnyObject {

    func categories() -> [DAppCategory]
}

// MARK: - DefaultDegenInteractor

class DefaultDegenInteractor {


    private var degenService: DegenService

    init(_ degenService: DegenService) {
        self.degenService = degenService
    }
}

// MARK: - DefaultDegenInteractor

extension DefaultDegenInteractor: DegenInteractor {

    func categories() -> [DAppCategory] {
        degenService.categories()
    }
}
