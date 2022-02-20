// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct Theme {

    static var current: Theme = Theme()

    // MARK: - Colors

    var tintPrimary: UIColor {
        UIColor.tintPrimary
    }

    var tintPrimaryLight: UIColor {
        UIColor.tintPrimary.withAlphaComponent(0.25)
    }

    var tintSecondary: UIColor {
        UIColor.tintSecondary
    }

    var background: UIColor {
        UIColor.bgGradientTop
    }

    var backgroundDark: UIColor {
        UIColor.bgGradientBottom
    }

    var textColor: UIColor {
        UIColor.textColor
    }

    var textColorSecondary: UIColor {
        UIColor.textColorSecondary
    }

    var textColorTertiary: UIColor {
        UIColor.textColorTertiary
    }

    var red: UIColor {
        UIColor.appRed
    }

    var green: UIColor {
        UIColor.appGreen
    }


    // MARK: - Fonts

    var body: UIFont {
        UIFont.font(.gothicA1, style: .regular, size: .body)
    }

    var navTitle: UIFont {
        UIFont.font(.nothingYouCouldDo, style: .regular, size: .custom(size: 24))
    }

    var callout: UIFont {
        UIFont.font(.gothicA1, style: .regular, size: .callout)
    }

    var subhead: UIFont {
        UIFont.font(.gothicA1, style: .regular, size: .subhead)
    }

    var mediumButton: UIFont {
        UIFont.font(.gothicA1, style: .medium, size: .subhead)
    }

    var hugeBalance: UIFont {
        UIFont.font(.gothicA1, style: .black, size: .custom(size: 48))
    }

    var footnote: UIFont {
        UIFont.font(.gothicA1, style: .regular, size: .footnote)
    }

    var tabBar: UIFont {
        UIFont.font(.gothicA1, style: .medium, size: .custom(size: 10))
    }

    var cellDetail: UIFont {
        UIFont.font(.gothicA1, style: .regular, size: .custom(size: 15))

    }
}

