// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeOG {
    
    var tint: UIColor { color.tint }
    
    var color: ThemeOGColor {
        
        DefaultThemeOGColor()
    }
        
    func font(for font: ThemeFont) -> UIFont {
        
        switch font {
            
        case .largeTitle:
            return .init(name: "GothicA1-Regular", size: 40)!
            
        case .navTitle:
            return .init(name: "NothingYouCouldDo-Regular", size: 24)!
            
        case .title1:
            return .init(name: "GothicA1-Bold", size: 28)!
            
        case .title2:
            return .init(name: "GothicA1-Bold", size: 26)!
            
        case .title3:
            return .init(name: "GothicA1-Bold", size: 24)!
            
        case .headline:
            return .init(name: "GothicA1-Regular", size: 18)!
            
        case .subheadline:
            return .init(name: "GothicA1-Regular", size: 14)!
            
        case .body:
            return .init(name: "GothicA1-Regular", size: 17)!
            
        case .callout:
            return .init(name: "GothicA1-Regular", size: 16)!
            
        case .caption1:
            return .init(name: "GothicA1-Regular", size: 13)!
            
        case .caption2:
            return .init(name: "GothicA1-Regular", size: 12)!
            
        case .footnote:
            return .init(name: "GothicA1-Regular", size: 11)!
        }
    }
    
    func colour(for colour: ThemeColour) -> UIColor {
        
        switch colour {
        case .text:
            return .init(named: "textColor")!
            
        case .orange:
            return .init(named: "orange")!
        }
    }
    
    var attributes: ThemeOGAttributes {
        
        DefaultThemeOGAttributes()
    }
    
    static var color: ThemeOGColor {
        
        DefaultThemeOGColor()
    }
    
    static var font: ThemeOGFont {
        
        DefaultThemeOGFont()
    }

    static var attributes: ThemeOGAttributes {
        
        DefaultThemeOGAttributes()
    }

}

