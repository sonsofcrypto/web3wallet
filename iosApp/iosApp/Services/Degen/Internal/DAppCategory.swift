// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DAppCategory {
    case swap
    case cult
    case stakeYield
    case landBorrow
    case derivative
    case bridge
    case mixer
    case governance

    static var active: [DAppCategory] {
        [.swap, .cult]
    }
    
    static var inactive: [DAppCategory] {
        [.stakeYield, .landBorrow, .derivative, .bridge, .mixer, .governance]
    }
}

