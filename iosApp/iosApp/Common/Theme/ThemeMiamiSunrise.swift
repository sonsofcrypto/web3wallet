// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeMiamiSunrise: ThemeProtocol {
    let name: String = "Miami Sunrise"
    let color: ThemeColorProtocol = ThemeColor()
    let supportedVariants: [ThemeVariant] = [.light, .dark]
    let statusBarStyle: UIStatusBarStyle = .lightContent
    let padding: CGFloat = 16
    let cornerRadius: CGFloat = 16
    let cornerRadiusSmall: CGFloat = 8
    let shadowRadius: CGFloat = 4
    let cellHeightLarge: CGFloat = 64
    let cellHeight: CGFloat = 46
    let sectionHeaderHeight: CGFloat = 46
    let buttonHeight: CGFloat = 46
    let buttonSmallHeight: CGFloat = 32
    let buttonHeightExtraSmall: CGFloat = 24
    let blurRadius: CGFloat = 16
    let blurTintAlpha: CGFloat = 0.18

    class ThemeColor: ThemeColorProtocol {
        var textPrimary: UIColor { Palette.white }
        var textSecondary: UIColor { Palette.white6 }
        var textTertiary: UIColor { Palette.white3 }
        var bgPrimary: UIColor { Palette.white18 }
        var bgGradientTop: UIColor { .init(variants: [Palette.blue, Palette.pink]) }
        var bgGradientBtm: UIColor { .init(variants: [Palette.pinkLight, Palette.purple]) }
        var navBarBackground: UIColor { Palette.lightBlack }
        var navBarTint: UIColor { Palette.orange }
        var navBarTitle: UIColor { Palette.white }
        var tabBarBackground: UIColor { Palette.lightBlack }
        var tabBarTint: UIColor { Palette.blue }
        var tabBarTintSelected: UIColor { Palette.pink }

        var collectionSectionStroke: UIColor { Palette.white01 }
        var collectionSeparator: UIColor { Palette.white18 }

        var stroke: UIColor { Palette.lightGray }
        var separatorPrimary: UIColor { Palette.lighterGray }
        var separatorSecondary: UIColor { Palette.white3 }
        var buttonBgPrimary: UIColor { .init(variants: [Palette.blue, Palette.pink]) }
        var buttonBgPrimaryDisabled: UIColor { Palette.gray }
        var buttonTextPrimary: UIColor { Palette.white }
        var buttonBgSecondary: UIColor { Palette.lightGray }
        var buttonTextSecondary: UIColor { Palette.white }
        var switchOnTint: UIColor { Palette.orange }
        var segmentedControlBackground: UIColor { Palette.lighterGray.withAlpha(0.1) }
        var segmentedControlBackgroundSelected: UIColor { Palette.white18 }
        var segmentedControlText: UIColor { Palette.white }
        var segmentedControlTextSelected: UIColor { Palette.white }
        var priceUp: UIColor { Palette.teal }
        var priceDown: UIColor { Palette.pink }
        var dashboardTVCryptoBalance: UIColor { Palette.orange }
        var activityIndicator: UIColor { Palette.white }
        var destructive: UIColor { Palette.red }
    }

    private struct Palette {
        static let black: UIColor = .black
        static let lightBlack: UIColor = .init(rgb: 0x1C1C1E)
        static let white: UIColor = .white
        static let white6: UIColor = .white.withAlpha(0.6)
        static let white3: UIColor = .white.withAlpha(0.3)
        static let white18: UIColor = .white.withAlpha(0.18)
        static let white01: UIColor = .white.withAlpha(0.1)
        static let red: UIColor = .init(variants: [.init(rgb: 0xE6350F), .init(rgb: 0xF0421D)])
        static let orange: UIColor = .init(variants: [.init(rgb: 0xF29A36), .init(rgb: 0xF08D1D)])
        static let teal: UIColor = .init(variants: [.init(rgb: 0x13CEC4), .init(rgb: 0x10B0A8)])
        static let blue: UIColor = .init(variants: [.init(rgb: 0x3770E6), .init(rgb: 0x4E80E9)])
        static let purple: UIColor = .init(variants: [.init(rgb: 0x9630B0), .init(rgb: 0x852B9C)])
        static let pink: UIColor = .init(variants: [.init(rgb: 0xF24A9B), .init(rgb: 0xF0328E)])
        static let pinkLight: UIColor = .init(rgb: 0xFC78A9)
        static let gray: UIColor = .init(rgb: 0x8E8E92)
        static let lightGray: UIColor = .init(variants: [.init(rgb: 0x787880).withAlpha(0.2), .init(rgb: 0x787880).withAlpha(0.36)])
        static let lighterGray: UIColor = .init(rgb: 0xC6C6C8)
    }

    // TODO(Anon): We should not keep this in memory at all times. Font palette + `.bold()`
    var font: ThemeFont = .init(
        largeTitle: .systemFont(ofSize: 34, weight: .regular), // line_height = 41
        largeTitleBold: .systemFont(ofSize: 34, weight: .bold), // line_height = 41
        title1: .systemFont(ofSize: 28, weight: .regular), // line_height = 34
        title1Bold: .systemFont(ofSize: 28, weight: .bold), // line_height = 34
        title2: .systemFont(ofSize: 22, weight: .regular), // line_height = 28
        title2Bold: .systemFont(ofSize: 22, weight: .bold), // line_height = 28
        title3: .systemFont(ofSize: 20, weight: .regular), // line_height = 25
        title3Bold: .systemFont(ofSize: 20, weight: .semibold), // line_height = 25
        headline: .systemFont(ofSize: 17, weight: .regular), // line_height = 22
        headlineBold: .systemFont(ofSize: 17, weight: .semibold), // line_height = 22
        subheadline: .systemFont(ofSize: 15, weight: .regular), // line_height = 20
        subheadlineBold: .systemFont(ofSize: 15, weight: .semibold), // line_height = 20
        body: .systemFont(ofSize: 17, weight: .regular), // line_height = 22
        bodyBold: .systemFont(ofSize: 17, weight: .semibold), // line_height = 22
        callout: .systemFont(ofSize: 16, weight: .regular), // line_height = 21
        calloutBold: .systemFont(ofSize: 16, weight: .semibold), // line_height = 21
        footnote: .systemFont(ofSize: 13, weight: .regular), // line_height = 18
        footnoteBold: .systemFont(ofSize: 13, weight: .semibold), // line_height = 18
        caption1: .systemFont(ofSize: 12, weight: .regular), // line_height = 16
        caption1Bold: .systemFont(ofSize: 12, weight: .semibold), // line_height = 16
        caption2: .systemFont(ofSize: 11, weight: .regular), // line_height = 13
        caption2Bold: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
        extraSmall: .systemFont(ofSize: 8, weight: .regular),
        extraSmallBold: .systemFont(ofSize: 8, weight: .semibold),
        navTitle: .systemFont(ofSize: 18, weight: .regular), // line_height = 20
        tabBar: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
        networkTitle: .init(name: "NaokoAA-BlackItalic", size: 16)!,
        dashboardSectionFuel: .init(name: "NaokoAA-RegularItalic", size: 11)!,
        dashboardTVBalance: .init(name: "OCR-A", size: 16)!,
        dashboardTVBalanceSmall: .init(name: "OCR-A", size: 11)!,
        dashboardTVSymbol: .init(name: "NaokoAA-Semilight", size: 13)!,
        dashboardTVPct: .init(name: "OCR-A", size: 10)!,
        dashboardTVTokenBalance: .init(name: "OCR-A", size: 13)!,
        dashboardTVTokenBalanceSmall: .init(name: "OCR-A", size: 8)!,

        sectionHeader: .systemFont(ofSize: 13, weight: .semibold),
        sectionFooter: .systemFont(ofSize: 15, weight: .regular)
)
}
