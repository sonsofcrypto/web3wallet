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
        let name = "themeA"
        return .init(
            gradientTop: .init(named: "\(name)-gradient-top")!,
            gradientBottom: .init(named: "\(name)-gradient-bottom")!,
            systemWhite: .init(named: "\(name)-system-white")!,
            systemRed: .init(named: "\(name)-system-red")!,
            systemOrange: .init(named: "\(name)-system-orange")!,
            systemYellow: .init(named: "\(name)-system-yellow")!,
            systemGreen: .init(named: "\(name)-system-green")!,
            systemTeal: .init(named: "\(name)-system-teal")!,
            systemBlue: .init(named: "\(name)-system-blue")!,
            systemMarine: .init(named: "\(name)-system-marine")!,
            systemPurple: .init(named: "\(name)-system-purple")!,
            systemPink:  .init(named: "\(name)-system-pink")!,
            systemGray: .init(named: "\(name)-system-gray")!,
            systemGray02: .init(named: "\(name)-system-gray02")!,
            systemGray03: .init(named: "\(name)-system-gray03")!,
            systemGray04: .init(named: "\(name)-system-gray04")!,
            systemGray05: .init(named: "\(name)-system-gray05")!,
            backgroundBasePrimary: .init(named: "\(name)-background-base-primary")!,
            backgroundBaseSecondary: .init(named: "\(name)-background-base-secondary")!,
            backgroundBaseTertiary: .init(named: "\(name)-background-base-tertiary")!,
            backgroundElevatedPrimary: .init(named: "\(name)-background-elevated-primary")!,
            fillPrimary: .init(named: "\(name)-fill-primary")!,
            fillSecondary: .init(named: "\(name)-fill-secondary")!,
            fillTertiary: .init(named: "\(name)-fill-tertiary")!,
            fillQuaternary: .init(named: "\(name)-fill-quaternary")!,
            separatorNoTransparency: .init(named: "\(name)-separator-no-transparency")!,
            separatorWithTransparency: .init(named: "\(name)-separator-with-transparency")!,
            navBarBackground: .init(named: "\(name)-nav-bar-background")!,
            navBarTint: .init(named: "\(name)-system-white")!,
            navBarTitle: .init(named: "\(name)-system-orange")!,
            tabBarBackground: .init(named: "\(name)-nav-bar-background")!,
            tabBarTint: .init(named: "\(name)-system-blue")!,
            tabBarTintSelected: .init(named: "\(name)-system-pink")!,
            labelPrimary: .init(named: "\(name)-label-primary")!,
            labelSecondary: .init(named: "\(name)-label-secondary")!,
            labelTertiary: .init(named: "\(name)-label-tertiary")!,
            labelQuaternary: .init(named: "\(name)-label-quaternary")!,
            buttonBackgroundPrimary: .init { traits in
                let pink = UIColor(named: "\(name)-system-pink")!
                let blue = UIColor(named: "\(name)-system-blue")!
                return traits.userInterfaceStyle == .dark ? pink : blue
            },
            buttonBackgroundSecondary: .init { traits in
                
                let light = UIColor(rgb: 0x787880).withAlpha(0.2)
                let dark = UIColor(rgb: 0x787880).withAlpha(0.36)
                return traits.userInterfaceStyle == .dark ? light : dark
            },
            switchTint: .init(named: "\(name)-separator-with-transparency")!.withAlpha(0.3),
            switchTintDisabled: .init(named: "\(name)-separator-with-transparency")!.withAlpha(0.6),
            switchOnTint: .init(named: "\(name)-system-orange")!,
            textFieldTextColour: .init(named: "\(name)-system-white")!,
            textFieldPlaceholderColour: .init(named: "\(name)-label-secondary")!,
            cellBackground: .init(named: "\(name)-fill-quaternary")!
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
