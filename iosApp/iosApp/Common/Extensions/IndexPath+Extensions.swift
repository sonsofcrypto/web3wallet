// Created by web3d3v on 19/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension IndexPath {

    func isZero() -> Bool {
        section == 0 && item == 0
    }

    static var zero: IndexPath = IndexPath(item: 0, section: 0)

    init(section: Int) {
        self.init(item: 0, section: section)
    }
}