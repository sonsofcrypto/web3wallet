// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DAppCategory: Equatable {
    
    case swap
    case cult
    case stakeYield
    case landBorrow
    case derivative
    case bridge
    case mixer
    case governance

    static func active(includingCult includeCult: Bool) -> [DAppCategory] {
        
        includeCult ? [.swap, .cult] : [.swap]
    }
    
    static var inactive: [DAppCategory] {
        [.stakeYield, .landBorrow, .derivative, .bridge, .mixer, .governance]
    }
}

