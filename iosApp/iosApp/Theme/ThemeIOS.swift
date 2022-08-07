// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeIOS: Themable {

    var name: String {
        "themeIOS"
    }
    
    var statusBarStyle: ThemeStatusBarStyle {
        
        .init(lightMode: .dark, darkMode: .light)
    }
    
    var type: ThemeType { .themeVanilla }
    
    var colour: ThemeColour {
        
        let pallete = ThemeColourPalette(name: name)
        return .init(
            gradientTop: .init { traits in
                traits.isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            gradientBottom: .init { traits in
                traits.isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            navBarBackground: .init { traits in
                traits.isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            navBarTint: pallete.systemOrange,
            navBarTitle: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            tabBarBackground: .init { traits in
                traits.isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            tabBarTint: pallete.systemBlue,
            tabBarTintSelected: pallete.systemPink,
            backgroundBasePrimary: .init { traits in
                traits.isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            backgroundBaseSecondary: .init { traits in
                traits.isDarkMode ?
                pallete.system1C1C1E :
                pallete.systemWhite
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
            fillTertiary: .init { traits in
                traits.isDarkMode ?
                pallete.system767680.withAlpha(0.24) :
                pallete.system767680.withAlpha(0.12)
            },
            fillQuaternary: .init { traits in
                traits.isDarkMode ?
                pallete.system767680.withAlpha(0.18) :
                pallete.system747480.withAlpha(0.08)
            },
            separator: .init { traits in
                traits.isDarkMode ?
                pallete.system38383A :
                pallete.systemC6C6C8
            },
            separatorTransparent: .init { traits in
                traits.isDarkMode ?
                pallete.system545458.withAlpha(0.65) :
                pallete.system3C3C43.withAlpha(0.36)
            },
            labelPrimary: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            labelSecondary: .init { traits in
                traits.isDarkMode ?
                pallete.systemEBEBF5.withAlpha(0.6) :
                pallete.system3C3C43.withAlpha(0.6)
            },
            labelTertiary: .init { traits in
                traits.isDarkMode ?
                pallete.systemEBEBF5.withAlpha(0.3) :
                pallete.system3C3C43.withAlpha(0.3)
            },
            labelQuaternary: .init { traits in
                traits.isDarkMode ?
                pallete.systemEBEBF5.withAlpha(0.18) :
                pallete.system3C3C43.withAlpha(0.18)
            },
            buttonBackgroundPrimary: pallete.systemBlue,
            buttonPrimaryText: pallete.systemWhite,
            buttonBackgroundSecondary: .init { traits in
                traits.isDarkMode ?
                pallete.system767680.withAlpha(0.24) :
                pallete.system767680.withAlpha(0.12)
            },
            buttonSecondaryText: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            switchThumbTintColor: pallete.systemWhite,
            switchBackgroundColor: .init { traits in
                traits.isDarkMode ?
                pallete.systemEBEBF5.withAlpha(0.6) :
                pallete.system3C3C43.withAlpha(0.3)
            },
            switchOnTint: pallete.systemOrange,
            switchDisabledThumbTint: .init { traits in
                traits.isDarkMode ?
                pallete.system48484A :
                pallete.systemC7C7CC
            },
            switchDisabledBackgroundColor: .init { traits in
                traits.isDarkMode ?
                pallete.system767680.withAlpha(0.24) :
                pallete.system767680.withAlpha(0.12)
            },
            textFieldTextColour: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            textFieldPlaceholderColour: .init { traits in
                traits.isDarkMode ?
                pallete.systemEBEBF5.withAlpha(0.6) :
                pallete.system3C3C43.withAlpha(0.6)
            },
            segmentedControlBackground: .init { traits in
                traits.isDarkMode ?
                pallete.system767680.withAlpha(0.24) :
                pallete.system767680.withAlpha(0.12)
            },
            segmentedControlBackgroundSelected: .init { traits in
                traits.isDarkMode ?
                pallete.system2C2C2E :
                pallete.systemWhite
            },
            segmentedControlText: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            segmentedControlTextSelected: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            cellBackground: .init { traits in
                traits.isDarkMode ?
                pallete.system1C1C1E :
                pallete.systemWhite
            },
            keystoreEnumFill: pallete.systemBlue,
            keystoreEnumText: pallete.systemWhite,
            priceUp: pallete.systemGreen,
            priceDown: pallete.systemRed,
            candleGreen: pallete.systemTeal,
            candleRed: pallete.systemPink,
            dashboardTVCryptoBallance: pallete.systemOrange,
            activityIndicator: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            toastAlertBackgroundColor: .init { traits in
                traits.isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            destructive: pallete.systemRed
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
            navTitle: .systemFont(ofSize: 20, weight: .regular), // line_height = 25
            tabBar: .systemFont(ofSize: 11, weight: .semibold), // line_height = 13
            networkTitle: .systemFont(ofSize: 15, weight: .regular),
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

private extension ThemeIOS {
    
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
        let system3C3C43: UIColor
        let systemF2F2F7: UIColor
        let system38383A: UIColor
        let systemC6C6C8: UIColor
        let system545458: UIColor
        let system787880: UIColor
        let system767680: UIColor
        let system747480: UIColor
        let system48484A: UIColor
        let systemC7C7CC: UIColor
        let system2C2C2E: UIColor
        
        init(name: String) {
                        
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
            self.system3C3C43 = .init(rgb: 0x3C3C43)
            self.systemF2F2F7 = .init(rgb: 0xF2F2F7)
            self.system38383A = .init(rgb: 0x38383A)
            self.system545458 = .init(rgb: 0x545458)
            self.systemC6C6C8 = .init(rgb: 0xC6C6C8)
            self.system787880 = .init(rgb: 0x787880)
            self.system767680 = .init(rgb: 0x767680)
            self.system747480 = .init(rgb: 0x747480)
            self.system48484A = .init(rgb: 0x48484A)
            self.systemC7C7CC = .init(rgb: 0xC7C7CC)
            self.system2C2C2E = .init(rgb: 0x2C2C2E)
        }
    }
}
