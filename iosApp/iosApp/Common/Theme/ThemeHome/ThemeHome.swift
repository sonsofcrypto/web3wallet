// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ThemeHome {
    
    func navBarColour() -> ThemeHomeNavBar
    func tabBarColour() -> ThemeHomeTabBar
    func gradient() -> ThemeHomeGradient
    func font(for font: ThemeHomeFont) -> UIFont
    func colour(for colour: ThemeHomeColour) -> UIColor
}

extension ThemeHome {
    
    func colour(for colour: ThemeHomeColour) -> UIColor {
        
        .init(named: colour.rawValue)!
    }
}
