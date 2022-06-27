// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum Theme {
    
    case themeHome(ThemeHome)
    //case themeBeach(ThemeBeach)
    case themeOG(ThemeOG)
}

extension Theme {
    
    var padding: CGFloat { 16 }
    
    var cornerRadius: CGFloat { 12 }
    
    func font(for font: ThemeFont) -> UIFont {
        
        switch self {
            
        case let .themeHome(themeHome):
            return themeHome.font(for: font)
            
        case let .themeOG(themeOG):
            return themeOG.font(for: font)
        }
    }
    
    func colour(for colour: ThemeColour) -> UIColor {
        
        switch self {
            
        case let .themeHome(themeHome):
            return themeHome.colour(for: colour)
            
        case let .themeOG(themeOG):
            return themeOG.colour(for: colour)
        }
    }
}
