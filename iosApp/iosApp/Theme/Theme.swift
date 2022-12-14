// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

var Theme: Themable = appTheme {
    didSet { AppDelegate.rebootApp() }
}

enum ThemeStyle: String {
    case light
    case dark
}

var appTheme: Themable {
    let service: SettingsService = AppAssembler.resolve()
    if service.isSelected(setting: .init(group: .theme, action: .themeMiamiLight)) {
        return ThemeMiami(style: .light)
    } else if service.isSelected(setting: .init(group: .theme, action: .themeMiamiDark)) {
        return ThemeMiami(style: .dark)
    } else if service.isSelected(setting: .init(group: .theme, action: .themeIosLight)) {
        return ThemeIOS(style: .light)
    } else {
        return ThemeIOS(style: .dark)
    }
}

protocol Themable {
    var name: String { get }
    var type: ThemeType { get }
    var font: ThemeFont { get }
    var color: ThemeColor { get }
    var statusBarStyle: ThemeStatusBarStyle { get }
    var padding: CGFloat { get }
    var cornerRadius: CGFloat { get }
    var cornerRadiusSmall: CGFloat { get }
    var shadowRadius: CGFloat { get }
    var cellHeight: CGFloat { get }
    var cellHeightSmall: CGFloat { get }
    var buttonHeight: CGFloat { get }
    var buttonSmallHeight: CGFloat { get }
    var buttonHeightExtraSmall: CGFloat { get }
}

extension Themable {
    
    var isThemeIOSDarkSelected: Bool {
        let service: SettingsService = AppAssembler.resolve()
        return service.isSelected(setting: .init(group: .theme, action: .themeIosDark))
    }
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
        case .unspecified: return .default
        case .light:
            switch lightMode {
            case .light: return .lightContent
            case .dark: return .darkContent
            }
        case .dark:
            switch darkMode {
            case .light: return .lightContent
            case .dark: return .darkContent
            }
        @unknown default: return .default
        }
    }
}

enum ThemeType {
    
    case themeMiami
    case themeVanilla
    
    var isThemeMiami: Bool {
        self == .themeMiami
    }
    
    var isThemeIOS: Bool {
        self == .themeVanilla
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
    let footnote: UIFont
    let footnoteBold: UIFont
    let caption1: UIFont
    let caption1Bold: UIFont
    let caption2: UIFont
    let caption2Bold: UIFont
    let extraSmall: UIFont
    let extraSmallBold: UIFont
    let navTitle: UIFont
    let tabBar: UIFont
    let networkTitle: UIFont
    let dashboardSectionFuel: UIFont
    let dashboardTVBalance: UIFont
    let dashboardTVBalanceSmall: UIFont
    let dashboardTVSymbol: UIFont
    let dashboardTVPct: UIFont
    let dashboardTVTokenBalance: UIFont
    let dashboardTVTokenBalanceSmall: UIFont
}

struct ThemeColor {
    let textPrimary: UIColor
    let textSecondary: UIColor
    let textTertiary: UIColor
    let bgPrimary: UIColor
    let bgGradientTop: UIColor
    let bgGradientBtm: UIColor
    let navBarBackground: UIColor
    let navBarTint: UIColor
    let navBarTitle: UIColor
    let tabBarBackground: UIColor
    let tabBarTint: UIColor
    let tabBarTintSelected: UIColor
    let stroke: UIColor
    let separatorPrimary: UIColor
    let separatorSecondary: UIColor
    let buttonBgPrimary: UIColor
    let ButtonBgPrimaryDisabled: UIColor
    let buttonTextPrimary: UIColor
    let buttonBgSecondary: UIColor
    let buttonTextSecondary: UIColor
    let switchOnTint: UIColor
    // TODO(Anon): Revisit, all of these are not necessary
    let segmentedControlBackground: UIColor
    let segmentedControlBackgroundSelected: UIColor
    let segmentedControlText: UIColor
    let segmentedControlTextSelected: UIColor
    let priceUp: UIColor
    let priceDown: UIColor
    let dashboardTVCryptoBalance: UIColor
    let activityIndicator: UIColor
    let destructive: UIColor
}
