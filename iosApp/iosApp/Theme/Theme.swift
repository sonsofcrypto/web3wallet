// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

var Theme: Themable = ThemeA()

protocol Themable {
    
    var statusBarStyle: ThemeStatusBarStyle { get }
    var type: ThemeType { get }
    var font: ThemeFont { get }
    var colour: ThemeColour { get }
    var constant: ThemeConstant { get }
}

struct ThemeStatusBarStyle {
    
    let lightMode: Style
    let darkMode: Style
    
    enum Style {
        case light
        case dark
    }
}

extension ThemeStatusBarStyle {
    
    func statusBarStyle(for interfaceStyle: UIUserInterfaceStyle) -> UIStatusBarStyle {
        
        switch interfaceStyle {
            
        case .unspecified:
            return .default
            
        case .light:
            switch lightMode {
            case .light:
                return .lightContent
            case .dark:
                return .darkContent
            }

        case .dark:
            switch darkMode {
            case .light:
                return .lightContent
            case .dark:
                return .darkContent
            }

        @unknown default:
            return .default
        }
    }
}

enum ThemeType {
    
    case themeA
    case themeIOS
    
    var isThemeA: Bool {
        
        self == .themeA
    }
    
    var isThemeIOS: Bool {
        
        self == .themeIOS
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
        
    let gradientTop: UIColor
    let gradientBottom: UIColor

    let navBarBackground: UIColor
    let navBarTint: UIColor
    let navBarTitle: UIColor

    let tabBarBackground: UIColor
    let tabBarTint: UIColor
    let tabBarTintSelected: UIColor
    
    let backgroundBasePrimary: UIColor
    let backgroundBaseSecondary: UIColor
    
    let fillPrimary: UIColor
    let fillSecondary: UIColor
    let fillTertiary: UIColor
    let fillQuaternary: UIColor

    let separatorNoTransparency: UIColor
    let separatorWithTransparency: UIColor
        
    let labelPrimary: UIColor
    let labelSecondary: UIColor
    let labelTertiary: UIColor
    let labelQuaternary: UIColor
    
    let buttonBackgroundPrimary: UIColor
    let buttonPrimaryText: UIColor
    let buttonBackgroundSecondary: UIColor
    let buttonSecondaryText: UIColor
        
    let switchTint: UIColor
    let switchTintDisabled: UIColor
    let switchOnTint: UIColor
    
    let textFieldTextColour: UIColor
    let textFieldPlaceholderColour: UIColor

    let segmentedControlBackground: UIColor
    let segmentedControlBackgroundSelected: UIColor
    let segmentedControlText: UIColor
    let segmentedControlTextSelected: UIColor

    let cellBackground: UIColor
    
    let keystoreEnumFill: UIColor
    let keystoreEnumText: UIColor
    
    let priceUp: UIColor
    let priceDown: UIColor
    let candleGreen: UIColor
    let candleRed: UIColor
    let dashboardTVCryptoBallance: UIColor
}

struct ThemeConstant {
    
    let cornerRadius: CGFloat
    let cornerRadiusSmall: CGFloat
    let shadowRadius: CGFloat
    let cellHeight: CGFloat
    let cellHeightSmall: CGFloat
    let padding: CGFloat
    let buttonPrimaryHeight: CGFloat
    let buttonSecondarySmallHeight: CGFloat
    let buttonDashboardActionHeight: CGFloat
}
