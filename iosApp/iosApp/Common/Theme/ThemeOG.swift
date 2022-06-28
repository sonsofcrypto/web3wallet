// Created by web3d4v on 28/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeOG: Themable {
    
    private let name: String = "ThemeOG"
    
    var type: ThemeType { .themeOG }

    var colour: ThemeColour {
        
        .init(
            systemRed: .init(named: "\(name)-system-red")!,
            systemOrange: .init(named: "\(name)-system-orange")!,
            systemYellow: .init(named: "\(name)-system-yellow")!,
            systemGreen: .init(named: "\(name)-system-green")!, //appGreen
            systemTeal: .init(named: "\(name)-system-teal")!,
            systemBlue: .init(named: "\(name)-system-blue")!,
            systemMarine: .init(named: "\(name)-system-marine")!,
            systemPurple: .init(named: "\(name)-system-purple")!,
            systemPink: .init(named: "\(name)-system-pink")!, //appRed
            systemGray: .init(named: "\(name)-system-gray")!,
            systemGray02: .init(named: "\(name)-system-gray02")!,
            systemGray03: .init(named: "\(name)-system-gray03")!,
            systemGray04: .init(named: "\(name)-system-gray04")!,
            systemGray05: .init(named: "\(name)-system-gray05")!,
            systemGray06: .init(named: "\(name)-system-gray06")!,
            backgroundBasePrimary: .init(named: "\(name)-background-base-primary")!, //bgGradientTop
            backgroundBaseSecondary: .init(named: "\(name)-background-base-secondary")!, //bgGradientTopSecondary
            backgroundBaseTertiary: .init(named: "\(name)-background-base-tertiary")!, //bgGradientBottom
            labelPrimary: .init(named: "\(name)-label-primary")!, //textColor
            labelSecondary: .init(named: "\(name)-label-secondary")!, //textColorSecondary
            labelTertiary: .init(named: "\(name)-label-tertiary")!, //textColorTertiary
            labelQuaternary: .init(named: "\(name)-label-quaternary")!,
            separatorNoTransparency: .init(named: "\(name)-separator-no-transparency")!,
            separatorWithTransparency: .init(named: "\(name)-separator-with-transparency")!,
            fillPrimary: .init(named: "\(name)-fill-primary")!, //tintPrimary
            fillSecondary: .init(named: "\(name)-fill-secondary")!, //tintSecondary
            fillTertiary: .init(named: "\(name)-fill-tertiary")!,
            fillQuaternary: .init(named: "\(name)-fill-quaternary")!
        )
    }
    
    var font: ThemeFont {
        
        .init(
            largeTitle: .init(name: "GothicA1-Regular", size: 40)!,
            navTitle: .init(name: "NothingYouCouldDo-Regular", size: 24)!,
            title1: .init(name: "GothicA1-Bold", size: 28)!,
            title2: .init(name: "GothicA1-Bold", size: 26)!,
            title3: .init(name: "GothicA1-Bold", size: 24)!,
            headline: .init(name: "GothicA1-Regular", size: 18)!,
            subheadline: .init(name: "GothicA1-Regular", size: 14)!,
            body: .init(name: "GothicA1-Regular", size: 17)!,
            callout: .init(name: "GothicA1-Regular", size: 16)!,
            caption1: .init(name: "GothicA1-Regular", size: 13)!,
            caption2: .init(name: "GothicA1-Regular", size: 12)!,
            footnote: .init(name: "GothicA1-Regular", size: 11)!,
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
