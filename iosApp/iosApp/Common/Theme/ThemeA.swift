// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeA: Themable {
    
    private let name: String = "themeA"
    
    var type: ThemeType { .themeA }
    
    var colour: ThemeColour {
        
        .init(
            systemRed: .init(named: "\(name)-system-red")!,
            systemOrange: .init(named: "\(name)-system-orange")!,
            systemYellow: .init(named: "\(name)-system-yellow")!,
            systemGreen: .init(named: "\(name)-system-green")!,
            systemTeal: .init(named: "\(name)-system-teal")!,
            systemBlue: .init(named: "\(name)-system-blue")!,
            systemMarine: .init(named: "\(name)-system-marine")!,
            systemPurple: .init(named: "\(name)-system-purple")!,
            systemPink: .init(named: "\(name)-system-pink")!,
            systemGray: .init(named: "\(name)-system-gray")!,
            systemGray02: .init(named: "\(name)-system-gray02")!,
            systemGray03: .init(named: "\(name)-system-gray03")!,
            systemGray04: .init(named: "\(name)-system-gray04")!,
            systemGray05: .init(named: "\(name)-system-gray05")!,
            systemGray06: .init(named: "\(name)-system-gray06")!,
            backgroundBasePrimary: .init(named: "\(name)-background-base-primary")!,
            backgroundBaseSecondary: .init(named: "\(name)-background-base-secondary")!,
            backgroundBaseTertiary: .init(named: "\(name)-background-base-tertiary")!,
            labelPrimary: .init(named: "\(name)-label-primary")!,
            labelSecondary: .init(named: "\(name)-label-secondary")!,
            labelTertiary: .init(named: "\(name)-label-tertiary")!,
            labelQuaternary: .init(named: "\(name)-label-quaternary")!,
            separatorNoTransparency: .init(named: "\(name)-separator-no-transparency")!,
            separatorWithTransparency: .init(named: "\(name)-separator-with-transparency")!,
            fillPrimary: .init(named: "\(name)-fill-primary")!,
            fillSecondary: .init(named: "\(name)-fill-secondary")!,
            fillTertiary: .init(named: "\(name)-fill-tertiary")!,
            fillQuaternary: .init(named: "\(name)-fill-quaternary")!
        )
    }
    
    var font: ThemeFont {
        
        .init(
            largeTitle: .init(name: "NaokoAA-Medium", size: 40)!,
            navTitle: .init(name: "NaokoAA-Regular", size: 18)!,
            title1: .init(name: "NaokoAA-Medium", size: 30)!,
            title2: .init(name: "NaokoAA-BlackItalic", size: 16)!,
            title3: .init(name: "NaokoAA-Medium", size: 40)!,
            headline: .init(name: "NaokoAA-Black", size: 16)!,
            subheadline: .init(name: "NaokoAA-Bold", size: 14)!,
            body: .init(name: "NaokoAA-Bold", size: 14)!,
            callout: .init(name: "NaokoAA-Bold", size: 16)!,
            caption1: .init(name: "NaokoAA-Bold", size: 14)!,
            caption2: .init(name: "NaokoAA-Bold", size: 14)!,
            footnote: .init(name: "NaokoAA-Bold", size: 14)!,
            tabBar: UIFont.font(.gothicA1, style: .medium, size: .custom(size: 10))
        )
    }
    
    var constant: ThemeConstant {
        
        .init(
            cornerRadius: 8,
            cornerRadiusSmall: 12,
            shadowRadius: 4,
            cellHeight: 64,
            cellHeightSmall: 46,
            padding: 16
        )
    }
}
