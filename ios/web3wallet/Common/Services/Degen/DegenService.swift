// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol DegenService: AnyObject {

    func categories() -> [DAppCategory]
}

class DefaultDegenService {

}

extension DefaultDegenService: DegenService {

    func categories() -> [DAppCategory] {
        DAppCategory.all()
    }
}
