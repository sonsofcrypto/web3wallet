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
    let largeTitleBold: UIFont
    let title1: UIFont
    let title1Bold: UIFont
    let title2: UIFont
    let title2Bold: UIFont
    let title3: UIFont
    let title3Bold: UIFont
    let headline: UIFont
    let headlineBold: UIFont
    let subheadline: UIFont
    let subheadlineBold: UIFont
    let body: UIFont
    let bodyBold: UIFont
    let callout: UIFont
    let calloutBold: UIFont
    let caption1: UIFont
    let caption1Bold: UIFont
    let caption2: UIFont
    let caption2Bold: UIFont
    let footnote: UIFont
    let footnoteBold: UIFont
    let navTitle: UIFont
    let tabBar: UIFont
    let networkTitle: UIFont
    let dashboardSectionFuel: UIFont
    let dashboardTVBalance: UIFont
    let dashboardTVSymbol: UIFont
    let dashboardTVPct: UIFont
    let dashboardTVTokenBalance: UIFont
}

struct ThemeColour {
    
    let navBarBackground: UIColor
    let navBarTint: UIColor
    let navBarTitle: UIColor

    let tabBarBackground: UIColor
    let tabBarTint: UIColor
    let tabBarTintSelected: UIColor
    
    let gradientTop: UIColor
    let gradientBottom: UIColor

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
    let backgroundElevatedPrimary: UIColor
    
    let labelPrimary: UIColor
    let labelSecondary: UIColor
    let labelTertiary: UIColor
    let labelQuaternary: UIColor
    
    let buttonBackgroundPrimary: UIColor
    let buttonBackgroundSecondary: UIColor
    let separatorNoTransparency: UIColor
    let separatorWithTransparency: UIColor
    
    let fillPrimary: UIColor
    let fillSecondary: UIColor
    let fillTertiary: UIColor
    let fillQuaternary: UIColor
    
    let switchTint: UIColor
    let switchTintDisabled: UIColor
    let switchOnTint: UIColor
    
    init(themeName name: String) {
        
        self.navBarBackground = .init(named: "\(name)-nav-bar-background")!
        self.navBarTint = .init(named: "\(name)-nav-bar-tint")!
        self.navBarTitle = .init(named: "\(name)-nav-bar-title")!
        self.tabBarBackground = .init(named: "\(name)-nav-bar-background")!
        self.tabBarTint = .init(named: "\(name)-tab-bar-tint")!
        self.tabBarTintSelected = .init(named: "\(name)-tab-bar-tint-selected")!
        self.gradientTop = .init(named: "\(name)-gradient-top")!
        self.gradientBottom = .init(named: "\(name)-gradient-bottom")!
        self.systemRed = .init(named: "\(name)-system-red")!
        self.systemOrange = .init(named: "\(name)-system-orange")!
        self.systemYellow = .init(named: "\(name)-system-yellow")!
        self.systemGreen = .init(named: "\(name)-system-green")!
        self.systemTeal = .init(named: "\(name)-system-teal")!
        self.systemBlue = .init(named: "\(name)-system-blue")!
        self.systemMarine = .init(named: "\(name)-system-marine")!
        self.systemPurple = .init(named: "\(name)-system-purple")!
        self.systemPink = .init(named: "\(name)-system-pink")!
        self.systemGray = .init(named: "\(name)-system-gray")!
        self.systemGray02 = .init(named: "\(name)-system-gray02")!
        self.systemGray03 = .init(named: "\(name)-system-gray03")!
        self.systemGray04 = .init(named: "\(name)-system-gray04")!
        self.systemGray05 = .init(named: "\(name)-system-gray05")!
        self.systemGray06 = .init(named: "\(name)-system-gray06")!
        self.backgroundBasePrimary = .init(named: "\(name)-background-base-primary")!
        self.backgroundBaseSecondary = .init(named: "\(name)-background-base-secondary")!
        self.backgroundBaseTertiary = .init(named: "\(name)-background-base-tertiary")!
        self.backgroundElevatedPrimary = .init(named: "\(name)-background-elevated-primary")!
        self.labelPrimary = .init(named: "\(name)-label-primary")!
        self.labelSecondary = .init(named: "\(name)-label-secondary")!
        self.labelTertiary = .init(named: "\(name)-label-tertiary")!
        self.labelQuaternary = .init(named: "\(name)-label-quaternary")!
        self.buttonBackgroundPrimary = .init(named: "\(name)-button-background-primary")!
        self.buttonBackgroundSecondary = .init(named: "\(name)-button-background-secondary")!
        self.separatorNoTransparency = .init(named: "\(name)-separator-no-transparency")!
        self.separatorWithTransparency = .init(named: "\(name)-separator-with-transparency")!
        self.fillPrimary = .init(named: "\(name)-fill-primary")!
        self.fillSecondary = .init(named: "\(name)-fill-secondary")!
        self.fillTertiary = .init(named: "\(name)-fill-tertiary")!
        self.fillQuaternary = .init(named: "\(name)-fill-quaternary")!
        self.switchTint = .init(named: "\(name)-switch-tint")!
        self.switchTintDisabled = .init(named: "\(name)-switch-tint-disabled")!
        self.switchOnTint = .init(named: "\(name)-switch-on-tint")!
    }
}

struct ThemeConstant {
    
    let cornerRadius: CGFloat
    let cornerRadiusSmall: CGFloat
    let shadowRadius: CGFloat
    let cellHeight: CGFloat
    let cellHeightSmall: CGFloat
    let padding: CGFloat
    let buttonPrimaryHeight: CGFloat
    let buttonDashboardActionHeight: CGFloat
}
