// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeA: Themable {
    
    var statusBarStyle: ThemeStatusBarStyle {
        
        .init(lightMode: .light, darkMode: .light)
    }
    
    var type: ThemeType { .themeA }
    
    var colour: ThemeColour {
        
        let pallete = ThemeColourPalette()
        return .init(
            gradientTop: .init { traits in
                traits.isDarkMode ? pallete.systemPink : pallete.systemBlue
            },
            gradientBottom: .init { traits in
                traits.isDarkMode ? pallete.systemYellow : pallete.systemPurple
            },
            navBarBackground: pallete.system1C1C1E,
            navBarTint: pallete.systemWhite,
            navBarTitle: pallete.systemOrange,
            tabBarBackground: pallete.system1C1C1E,
            tabBarTint: pallete.systemBlue,
            tabBarTintSelected: pallete.systemPink,
            backgroundBasePrimary: pallete.systemBlack,
            backgroundBaseSecondary: .init { traits in
                traits.isDarkMode ?
                pallete.system1C1C1E :
                pallete.systemF2F2F7
            },
            fillPrimary: .init { traits in
                traits.isDarkMode ?
                pallete.system787880.withAlpha(0.36) :
                pallete.system787880.withAlpha(0.2)
            },
            fillSecondary: .init { traits in
                traits.isDarkMode ?
                pallete.system787880.withAlpha(0.32) :
                pallete.system787880.withAlpha(0.16)
            },
            fillTertiary: pallete.system767680,
            fillQuaternary: pallete.systemEBEBF5.withAlpha(0.18),
            separatorNoTransparency: pallete.systemC6C6C8,
            separatorWithTransparency: pallete.systemEBEBF5.withAlpha(0.3),
            labelPrimary: pallete.systemWhite,
            labelSecondary: pallete.systemEBEBF5.withAlpha(0.6),
            labelTertiary: pallete.systemEBEBF5.withAlpha(0.3),
            labelQuaternary: pallete.systemEBEBF5.withAlpha(0.18),
            buttonBackgroundPrimary: .init { traits in
                traits.isDarkMode ? pallete.systemPink : pallete.systemBlue
            },
            buttonBackgroundSecondary: .init { traits in
                traits.isDarkMode ?
                pallete.system787880.withAlpha(0.36) :
                pallete.system787880.withAlpha(0.2)
            },
            switchTint: pallete.systemEBEBF5.withAlpha(0.3),
            switchTintDisabled: pallete.systemEBEBF5.withAlpha(0.6),
            switchOnTint: pallete.systemOrange,
            textFieldTextColour: pallete.systemWhite,
            textFieldPlaceholderColour: pallete.systemEBEBF5.withAlpha(0.6),
            cellBackground: pallete.systemEBEBF5.withAlpha(0.18),
            keystoreEnumFill: pallete.systemBlue,
            priceUp: pallete.systemGreen,
            priceDown: pallete.systemRed,
            candleGreen: pallete.systemTeal,
            candleRed: pallete.systemPink,
            dashboardTVCryptoBallance: pallete.systemOrange
        )
    }
    
    var font: ThemeFont {
        
        .init(
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
            caption1: .systemFont(ofSize: 12, weight: .regular), // line_height = 16
            caption1Bold: .systemFont(ofSize: 12, weight: .semibold), // line_height = 16
            caption2: .systemFont(ofSize: 11, weight: .regular), // line_height = 13
            caption2Bold: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
            footnote: .systemFont(ofSize: 13, weight: .regular), // line_height = 18
            footnoteBold: .systemFont(ofSize: 13, weight: .semibold), // line_height = 18
            navTitle: .systemFont(ofSize: 18, weight: .regular), // line_height = 20
            tabBar: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
            networkTitle: .init(name: "NaokoAA-BlackItalic", size: 16)!,
            dashboardSectionFuel: .init(name: "NaokoAA-RegularItalic", size: 11)!,
            dashboardTVBalance: .init(name: "OCR-A", size: 16)!,
            dashboardTVSymbol: .init(name: "NaokoAA-Semilight", size: 13)!,
            dashboardTVPct: .init(name: "OCR-A", size: 10)!,
            dashboardTVTokenBalance: .init(name: "OCR-A", size: 13)!
        )
    }
    
    var constant: ThemeConstant {
        
        .init(
            cornerRadius: 14,
            cornerRadiusSmall: 8,
            shadowRadius: 4,
            cellHeight: 64,
            cellHeightSmall: 46,
            padding: 16,
            buttonPrimaryHeight: 46,
            buttonSecondarySmallHeight: 24,
            buttonDashboardActionHeight: 32
        )
    }
}

private extension ThemeA {
    
    struct ThemeColourPalette {
        
        let systemBlack: UIColor
        let systemWhite: UIColor
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
        let systemEBEBF5: UIColor
        let system1C1C1E: UIColor
        let systemC6C6C8: UIColor
        let systemF2F2F7: UIColor
        let system787880: UIColor
        let system767680: UIColor
        
        init(name: String = "themeA") {
                        
            self.systemBlack = .init(named: "\(name)-system-black")!
            self.systemBlue = .init(named: "\(name)-system-blue")!
            self.systemGreen = .init(named: "\(name)-system-green")!
            self.systemGray = .init(named: "\(name)-system-gray")!
            self.systemMarine = .init(named: "\(name)-system-marine")!
            self.systemOrange = .init(named: "\(name)-system-orange")!
            self.systemPurple = .init(named: "\(name)-system-purple")!
            self.systemPink =  .init(named: "\(name)-system-pink")!
            self.systemRed = .init(named: "\(name)-system-red")!
            self.systemTeal = .init(named: "\(name)-system-teal")!
            self.systemWhite = .init(named: "\(name)-system-white")!
            self.systemYellow = .init(named: "\(name)-system-yellow")!
            self.systemEBEBF5 = .init(rgb: 0xEBEBF5)
            self.system1C1C1E = .init(rgb: 0x1C1C1E)
            self.systemC6C6C8 = .init(rgb: 0xC6C6C8)
            self.systemF2F2F7 = .init(rgb: 0xF2F2F7)
            self.system787880 = .init(rgb: 0x787880)
            self.system767680 = .init(rgb: 0x767680)
        }
    }
}
