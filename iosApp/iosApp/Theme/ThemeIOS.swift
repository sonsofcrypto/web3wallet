// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeIOS: Themable {
    let style: ThemeStyle
    let name: String = "themeIOS"
    let type: ThemeType = .themeVanilla

    let padding: CGFloat = 16
    let cornerRadius: CGFloat = 14
    let cornerRadiusSmall: CGFloat = 8
    let shadowRadius: CGFloat = 4
    let cellHeight: CGFloat = 64
    let cellHeightSmall: CGFloat = 46
    let buttonHeight: CGFloat = 46
    let buttonSmallHeight: CGFloat = 32
    let buttonHeightExtraSmall: CGFloat = 24

    init(style: ThemeStyle) {
        self.style = style
    }

    var statusBarStyle: ThemeStatusBarStyle {
        isDarkMode
        ? .init(lightMode: .light, darkMode: .light)
        : .init(lightMode: .dark, darkMode: .dark)
    }

    var color: ThemeColor {
        
        let pallete = ThemeColourPalette(isDarkMode: isDarkMode)
        return .init(
            textPrimary: .init { traits in
                isDarkMode ?
                    pallete.systemWhite :
                    pallete.systemBlack
            },
            textSecondary: .init { traits in
                isDarkMode ?
                    pallete.systemEBEBF5.withAlpha(0.6) :
                    pallete.system3C3C43.withAlpha(0.6)
            },
            textTertiary: .init { traits in
                isDarkMode ?
                    pallete.systemEBEBF5.withAlpha(0.3) :
                    pallete.system3C3C43.withAlpha(0.3)
            },
            bgPrimary: .init { traits in
                isDarkMode ?
                    pallete.system1C1C1E :
                    pallete.systemWhite
            },
            bgGradientTop: .init { traits in
                isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            bgGradientBtm: .init { traits in
                isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            navBarBackground: .init { traits in
                isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            navBarTint: pallete.systemOrange,
            navBarTitle: .init { traits in
                isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            tabBarBackground: .init { traits in
                isDarkMode ?
                pallete.systemBlack :
                pallete.systemF2F2F7
            },
            tabBarTint: pallete.systemBlue,
            tabBarTintSelected: pallete.systemPink,
            stroke: .init { traits in
                isDarkMode ?
                pallete.system787880.withAlpha(0.36) :
                pallete.system787880.withAlpha(0.2)
            },
            separatorPrimary: .init { traits in
                isDarkMode ?
                pallete.system38383A :
                pallete.systemC6C6C8
            },
            separatorSecondary: .init { traits in
                isDarkMode ?
                pallete.system545458.withAlpha(0.65) :
                pallete.system3C3C43.withAlpha(0.36)
            },
            buttonBgPrimary: pallete.systemBlue,
            ButtonBgPrimaryDisabled: pallete.systemGray,
            buttonTextPrimary: pallete.systemWhite,
            buttonBgSecondary: .init { traits in
                isDarkMode ?
                pallete.system767680.withAlpha(0.24) :
                pallete.system767680.withAlpha(0.12)
            },
            buttonTextSecondary: .init { traits in
                isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            switchOnTint: pallete.systemOrange,
            segmentedControlBackground: .init { traits in
                isDarkMode ?
                pallete.system767680.withAlpha(0.24) :
                pallete.system767680.withAlpha(0.12)
            },
            segmentedControlBackgroundSelected: .init { traits in
                isDarkMode ?
                pallete.system2C2C2E :
                pallete.systemWhite
            },
            segmentedControlText: .init { traits in
                isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            segmentedControlTextSelected: .init { traits in
                isDarkMode ?
                pallete.systemWhite :
                pallete.systemBlack
            },
            priceUp: pallete.systemGreen,
            priceDown: pallete.systemRed,
            dashboardTVCryptoBalance: pallete.systemOrange,
            activityIndicator: .init { traits in
                isDarkMode ?
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
            dashboardTVTokenBalanceSmall: .init(name: "OCR-A", size: 8)!
        )
    }


}

private extension ThemeIOS {
    
    var isDarkMode: Bool {
        switch style {
        case .dark:
            return true
        case .light:
            return false
        }
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
        
        init(isDarkMode: Bool) {
                        
            self.systemBlack = .init(rgb: 0x000000)
            self.systemBlue = .init { traits in
                isDarkMode ?
                .init(rgb: 0x4E80E9) :
                .init(rgb: 0x376FE6)
            }
            self.systemGray = .init(rgb: 0x8E8E92)
            self.systemGreen = .init { traits in
                isDarkMode ?
                .init(rgb: 0x78D539) :
                .init(rgb: 0x85DA4E)
            }
            self.systemMarine = .init { traits in
                isDarkMode ?
                .init(rgb: 0x2C52A0) :
                .init(rgb: 0x305CB4)
            }
            self.systemOrange = .init { traits in
                isDarkMode ?
                .init(rgb: 0xF08D1D) :
                .init(rgb: 0xF29A36)
            }
            self.systemPurple = .init { traits in
                isDarkMode ?
                .init(rgb: 0x852B9C) :
                .init(rgb: 0x952FAF)
            }
            self.systemPink = .init { traits in
                isDarkMode ?
                .init(rgb: 0xEF318E) :
                .init(rgb: 0xF1499B)
            }
            self.systemRed = .init { traits in
                isDarkMode ?
                .init(rgb: 0xEF421D) :
                .init(rgb: 0xE6350F)
            }
            self.systemTeal = .init { traits in
                isDarkMode ?
                .init(rgb: 0x10AFA8) :
                .init(rgb: 0x13CEC4)
            }
            self.systemWhite = .init(rgb: 0xFFFFFF)
            self.systemYellow = .init { traits in
                isDarkMode ?
                .init(rgb: 0xEFC21D) :
                .init(rgb: 0xF1C836)
            }
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
