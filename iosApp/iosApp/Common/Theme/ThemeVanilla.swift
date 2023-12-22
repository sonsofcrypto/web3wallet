// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

struct ThemeVanilla: ThemeProtocol {
    let name: String = "Vanilla"
    let id: ThemeId = ThemeId.vanilla
    let color: ThemeColorProtocol = ThemeColor()
    let supportedVariants: [ThemeVariant] = [.light, .dark]
    let statusBarStyle: UIStatusBarStyle = .default
    let padding: CGFloat = 16
    let paddingHalf: CGFloat = 8
    let cornerRadius: CGFloat = 14
    let cellHeightLarge: CGFloat = 64
    let cellHeight: CGFloat = 46
    let lineHeight: CGFloat = 0.666667
    let buttonHeight: CGFloat = 46
    let buttonSmallHeight: CGFloat = 32
    let buttonHeightExtraSmall: CGFloat = 24
    let buttonInCellHeight: CGFloat = 32

    class ThemeColor: ThemeColorProtocol {
        var textPrimary: UIColor { .label }
        var textSecondary: UIColor { .secondaryLabel }
        var textTertiary: UIColor { .tertiaryLabel }

        var bgPrimary: UIColor { .secondarySystemBackground }
        var bgSecondary: UIColor { .tertiarySystemBackground }
        var bgBlurTint: UIColor { .secondarySystemBackground }
        var bgGradientTop: UIColor { .systemBackground }
        var bgGradientBtm: UIColor { .systemBackground }

        var navBarBackground: UIColor { .systemBackground }
        var navBarTint: UIColor { Palette.orange }
        var navBarTitle: UIColor { .label }

        var tabBarBackground: UIColor { .systemBackground }
        var tabBarTint: UIColor { Palette.blue }
        var tabBarTintSelected: UIColor { Palette.pink }

        var collectionSectionStroke: UIColor { UIColor.quaternaryLabel.withAlpha(0.1) }
        var collectionSeparator: UIColor { .quaternaryLabel }

        var separator: UIColor { .tertiaryLabel }
        var buttonBgPrimary: UIColor { Palette.blue }
        var buttonBgSecondary: UIColor { .secondarySystemBackground }
        var switchOnTint: UIColor { Palette.orange }

        var priceUp: UIColor { Palette.green }
        var priceDown: UIColor { Palette.red }
        var dashboardTVCryptoBalance: UIColor { Palette.orange }
        var destructive: UIColor { Palette.red }
    }

    private struct Palette {
        static let orange: UIColor = .init(variants: [.init(rgb: 0xF29A36), .init(rgb: 0xF08D1D)])
        static let blue: UIColor = .init(variants: [.init(rgb: 0x376FE6), .init(rgb: 0x4E80E9)])
        static let pink: UIColor = .init(variants: [.init(rgb: 0xEF318E), .init(rgb: 0xEF318E)])
        static let red: UIColor = .init(variants: [.init(rgb: 0xE6350F), .init(rgb: 0xEF421D)])
        static let green: UIColor = .init(variants: [.init(rgb: 0x13CEC4), .init(rgb: 0x10AFA8)])
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
        callout: .systemFont(ofSize: 16, weight: .regular),  // line_height = 21
        calloutBold: .systemFont(ofSize: 16, weight: .semibold),  // line_height = 21
        footnote: .systemFont(ofSize: 13, weight: .regular), // line_height = 18
        footnoteBold: .systemFont(ofSize: 13, weight: .semibold), // line_height = 18
        caption1: .systemFont(ofSize: 12, weight: .regular), // line_height = 16
        caption1Bold: .systemFont(ofSize: 12, weight: .semibold), // line_height = 16
        caption2: .systemFont(ofSize: 11, weight: .regular), // line_height = 13
        caption2Bold: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
        extraSmall: .systemFont(ofSize: 8, weight: .regular), // line_height = 13
        extraSmallBold: .systemFont(ofSize: 8, weight: .semibold), // line_height = 13
        navTitle: .systemFont(ofSize: 20, weight: .regular), // line_height = 25
        tabBar: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
        networkTitle: .systemFont(ofSize: 15, weight: .regular),
        dashboardSectionFuel: .init(name: "NaokoAA-RegularItalic", size: 11)!,
        dashboardTVBalance: .init(name: "OCR-A", size: 16)!,
        dashboardTVBalanceSmall: .init(name: "OCR-A", size: 11)!,
        dashboardTVSymbol: .init(name: "NaokoAA-Semilight", size: 13)!,
        dashboardTVPct: .init(name: "OCR-A", size: 10)!,
        dashboardTVTokenBalance: .init(name: "OCR-A", size: 13)!,
        dashboardTVTokenBalanceSmall: .init(name: "OCR-A", size: 8)!,
        sectionHeader: .systemFont(ofSize: 13, weight: .regular),
        sectionFooter: .systemFont(ofSize: 15, weight: .regular)
)

    static func isCurrent() -> Bool {
        (Theme as? ThemeVanilla) != nil
    }
}
