// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeMiami: Themable {
    
    let style: ThemeStyle
    
    init(
        style: ThemeStyle
    ) {
        self.style = style
    }
    
    var name: String { "themeMiami" }
    var type: ThemeType { .themeMiami }

    var statusBarStyle: ThemeStatusBarStyle {
        .init(lightMode: .light, darkMode: .light)
    }

    var colour: ThemeColour {
        let pallete = ThemeColourPalette(isDarkMode: isDarkMode)
        return .init(
            gradientTop: .init { traits in
                isDarkMode ? pallete.systemPink : pallete.systemBlue
            },
            gradientBottom: .init { traits in
                isDarkMode ? pallete.systemPurple : pallete.systemFC78A9
            },
            navBarBackground: pallete.system1C1C1E,
            navBarTint: pallete.systemOrange,
            navBarTitle: pallete.systemWhite,
            tabBarBackground: pallete.system1C1C1E,
            tabBarTint: pallete.systemBlue,
            tabBarTintSelected: pallete.systemPink,
            backgroundBasePrimary: pallete.systemBlack,
            backgroundBaseSecondary: .init { traits in
                isDarkMode ?
                pallete.system1C1C1E :
                pallete.systemF2F2F7
            },
            fillPrimary: .init { traits in
                isDarkMode ?
                pallete.system787880.withAlpha(0.36) :
                pallete.system787880.withAlpha(0.2)
            },
            fillSecondary: .init { traits in
                isDarkMode ?
                pallete.system787880.withAlpha(0.32) :
                pallete.system787880.withAlpha(0.16)
            },
            fillTertiary: pallete.system767680,
            fillQuaternary: pallete.systemEBEBF5.withAlpha(0.18),
            separator: pallete.systemC6C6C8,
            separatorTransparent: pallete.systemEBEBF5.withAlpha(0.3),
            labelPrimary: pallete.systemWhite,
            labelSecondary: pallete.systemEBEBF5.withAlpha(0.6),
            labelTertiary: pallete.systemEBEBF5.withAlpha(0.3),
            labelQuaternary: pallete.systemEBEBF5.withAlpha(0.18),
            buttonBackgroundPrimary: .init { traits in
                isDarkMode ? pallete.systemPink : pallete.systemBlue
            },
            buttonPrimaryText: pallete.systemWhite,
            buttonBackgroundSecondary: .init { traits in
                isDarkMode ?
                pallete.system787880.withAlpha(0.36) :
                pallete.system787880.withAlpha(0.2)
            },
            buttonSecondaryText: pallete.systemWhite,
            switchThumbTintColor: pallete.systemWhite,
            switchBackgroundColor: pallete.systemEBEBF5.withAlpha(0.3),
            switchOnTint: pallete.systemOrange,
            switchDisabledThumbTint: pallete.systemEBEBF5.withAlpha(0.6),
            switchDisabledBackgroundColor: .init { traits in
                isDarkMode ?
                pallete.system787880.withAlpha(0.32) :
                pallete.system787880.withAlpha(0.16)
            },
            textFieldTextColour: pallete.systemWhite,
            textFieldPlaceholderColour: pallete.systemEBEBF5.withAlpha(0.6),
            segmentedControlBackground: .init { traits in
                isDarkMode ?
                pallete.system767680.withAlpha(0.18) :
                pallete.system767680.withAlpha(0.08)
            },
            segmentedControlBackgroundSelected: pallete.systemEBEBF5.withAlpha(0.18),
            segmentedControlText: pallete.systemWhite,
            segmentedControlTextSelected: pallete.systemWhite,
            cellBackground: .init { traits in
                isDarkMode ?
                pallete.systemEBEBF5.withAlpha(0.18) :
                pallete.systemEBEBF5.withAlpha(0.18)
                //pallete.systemBlack.withAlpha(0.2)
            },
            keystoreEnumFill: pallete.systemBlue,
            keystoreEnumText: pallete.systemWhite,
            priceUp: pallete.systemGreen,
            priceDown: pallete.systemRed,
            candleGreen: pallete.systemTeal,
            candleRed: pallete.systemPink,
            dashboardTVCryptoBallance: pallete.systemOrange,
            activityIndicator: pallete.systemWhite,
            toastAlertBackgroundColor: pallete.system1C1C1E,
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
            cornerRadius: 16,
            cornerRadiusSmall: 8,
            shadowRadius: 4,
            cellHeight: 64,
            cellHeightSmall: 46,
            padding: 16,
            buttonPrimaryHeight: 46,
            buttonSecondaryHeight: 46,
            buttonSecondarySmallHeight: 24,
            buttonDashboardActionHeight: 32
        )
    }
}

private extension ThemeMiami {
    
    var isDarkMode: Bool {
        switch style {
        case .dark:
            return true
        case .light:
            return false
        }
    }
}

private extension ThemeMiami {
    
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
        let systemFC78A9: UIColor
        
        init(isDarkMode: Bool) {
                        
            self.systemBlack = .init(rgb: 0x000000)
            self.systemBlue = .init { traits in
                isDarkMode ?
                .init(rgb: 0x4E80E9) :
                .init(rgb: 0x3770E6)
            }
            self.systemGray = .init(rgb: 0x8E8E92)
            self.systemGreen = .init { traits in
                isDarkMode ?
                .init(rgb: 0x78D63A) :
                .init(rgb: 0x85DA4E)
            }
            self.systemMarine = .init { traits in
                isDarkMode ?
                .init(rgb: 0x2C52A1) :
                .init(rgb: 0x315CB4)
            }
            self.systemOrange = .init { traits in
                isDarkMode ?
                .init(rgb: 0xF08D1D) :
                .init(rgb: 0xF29A36)
            }
            self.systemPurple = .init { traits in
                isDarkMode ?
                .init(rgb: 0x852B9C) :
                .init(rgb: 0x9630B0)
            }
            self.systemPink = .init { traits in
                isDarkMode ?
                .init(rgb: 0xF0328E) :
                .init(rgb: 0xF24A9B)
            }
            self.systemRed = .init { traits in
                isDarkMode ?
                .init(rgb: 0xF0421D) :
                .init(rgb: 0xE6350F)
            }
            self.systemTeal = .init { traits in
                isDarkMode ?
                .init(rgb: 0x10B0A8) :
                .init(rgb: 0x13CEC4)
            }
            self.systemWhite = .init(rgb: 0xFFFFFF)
            self.systemYellow = .init { traits in
                isDarkMode ?
                .init(rgb: 0xF0C21D) :
                .init(rgb: 0xF2C936)
            }
            self.systemEBEBF5 = .init(rgb: 0xEBEBF5)
            self.system1C1C1E = .init(rgb: 0x1C1C1E)
            self.systemC6C6C8 = .init(rgb: 0xC6C6C8)
            self.systemF2F2F7 = .init(rgb: 0xF2F2F7)
            self.system787880 = .init(rgb: 0x787880)
            self.system767680 = .init(rgb: 0x767680)
            self.systemFC78A9 = .init(rgb: 0xFC78A9)
        }
    }
}
