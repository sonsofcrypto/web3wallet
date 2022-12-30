// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

var Theme: ThemeProtocol = initialize() {
    didSet { AppDelegate.rebootApp() }
}

enum ThemeVariant: String {
    case light
    case dark
}

protocol ThemeProtocol {
    var name: String { get }
    var color: ThemeColorProtocol { get }
    var font: ThemeFont { get }
    var supportedVariants: [ThemeVariant] { get }
    var statusBarStyle: UIStatusBarStyle { get }
    // TODO(Anon): To be consolidated further
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

// TODO(Anon): This can be further consolidated
protocol ThemeColorProtocol {
    var textPrimary: UIColor { get }
    var textSecondary: UIColor { get }
    var textTertiary: UIColor { get }
    var bgPrimary: UIColor { get }
    var bgGradientTop: UIColor { get }
    var bgGradientBtm: UIColor { get }
    var navBarBackground: UIColor { get }
    var navBarTint: UIColor { get }
    var navBarTitle: UIColor { get }
    var tabBarBackground: UIColor { get }
    var tabBarTint: UIColor { get }
    var tabBarTintSelected: UIColor { get }
    var stroke: UIColor { get }
    var separatorPrimary: UIColor { get }
    var separatorSecondary: UIColor { get }
    var buttonBgPrimary: UIColor { get }
    var buttonBgPrimaryDisabled: UIColor { get }
    var buttonTextPrimary: UIColor { get }
    var buttonBgSecondary: UIColor { get }
    var buttonTextSecondary: UIColor { get }
    var switchOnTint: UIColor { get }
    // TODO(Anon): Definitely dont need all this for segmented control
    var segmentedControlBackground: UIColor { get }
    var segmentedControlBackgroundSelected: UIColor { get }
    var segmentedControlText: UIColor { get }
    var segmentedControlTextSelected: UIColor { get }
    var priceUp: UIColor { get }
    var priceDown: UIColor { get }
    var dashboardTVCryptoBalance: UIColor { get }
    var activityIndicator: UIColor { get }
    var destructive: UIColor { get }
}

// TODO(Anon): This is way too many fonts. Need to consolidate.
// TODO(Anon): Create font palette and move to protocol (like colors)
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

// TODO: This is comment on settings. It should be `Settings.theme`
// `Settings.variat` thi complexity is way too much and too hard to understand
private func initialize() ->  ThemeProtocol {
    let service: SettingsService = AppAssembler.resolve()
    if service.isSelected(setting: .init(group: .theme, action: .themeMiamiLight)) {
        AppDelegate.setUserInterfaceStyle(.light)
        return ThemeMiamiSunrise()
    } else if service.isSelected(setting: .init(group: .theme, action: .themeMiamiDark)) {
        AppDelegate.setUserInterfaceStyle(.dark)
        return ThemeMiamiSunrise()
    } else if service.isSelected(setting: .init(group: .theme, action: .themeIosLight)) {
        AppDelegate.setUserInterfaceStyle(.light)
        return ThemeVanilla()
    } else {
        AppDelegate.setUserInterfaceStyle(.dark)
        return ThemeVanilla()
    }
}