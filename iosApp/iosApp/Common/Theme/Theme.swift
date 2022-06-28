// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

var Theme: Themable = ThemeA()

protocol Themable {
    
    var type: ThemeType { get }
    var font: ThemeFont { get }
    var colour: ThemeColour { get }
    var constant: ThemeConstant { get }
}

enum ThemeType {
    
    case themeA
    case themeOG
    
    var isThemeA: Bool {
        
        self == .themeA
    }
    
    var isThemeOG: Bool {
        
        self == .themeOG
    }
}

struct ThemeFont {
    
    let largeTitle: UIFont
    let navTitle: UIFont
    let title1: UIFont
    let title2: UIFont
    let title3: UIFont
    let headline: UIFont
    let subheadline: UIFont
    let body: UIFont
    let callout: UIFont
    let caption1: UIFont
    let caption2: UIFont
    let footnote: UIFont
    let tabBar: UIFont
}

struct ThemeColour {
    
    let systemRed: UIColor
    let systemOrange: UIColor
    let systemYellow: UIColor
    let systemGreen: UIColor
    let systemTeal: UIColor
    let systemBlue: UIColor
    let systemMarine: UIColor
    let systemPurple: UIColor
    let systemPink: UIColor
    
    let systemGray: UIColor
    let systemGray02: UIColor
    let systemGray03: UIColor
    let systemGray04: UIColor
    let systemGray05: UIColor
    let systemGray06: UIColor
    
    let backgroundBasePrimary: UIColor
    let backgroundBaseSecondary: UIColor
    let backgroundBaseTertiary: UIColor
    
    let labelPrimary: UIColor
    let labelSecondary: UIColor
    let labelTertiary: UIColor
    let labelQuaternary: UIColor
    
    let separatorNoTransparency: UIColor
    let separatorWithTransparency: UIColor
    
    let fillPrimary: UIColor
    let fillSecondary: UIColor
    let fillTertiary: UIColor
    let fillQuaternary: UIColor
}

struct ThemeConstant {
    
    let cornerRadius: CGFloat
    let cornerRadiusSmall: CGFloat
    let shadowRadius: CGFloat
    let cellHeight: CGFloat
    let cellHeightSmall: CGFloat
    let padding: CGFloat
}
