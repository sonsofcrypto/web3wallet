// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DAppCategory {
    case amm
    case stakeYield
    case landBorrow
    case derivative
    case bridge
    case mixer
    case governance

    static func all() -> [DAppCategory] {
        [amm, stakeYield, landBorrow, derivative, bridge, mixer, governance]
    }
}

