// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol ThemeOGColor {

    var tint: UIColor { get }
    var tintLight: UIColor { get }
    var tintSecondary: UIColor { get }
    var background: UIColor { get }
    var backgroundDark: UIColor { get }
    var text: UIColor { get }
    var textSecondary: UIColor { get }
    var textTertiary: UIColor { get }
    var red: UIColor { get }
    var green: UIColor { get }
}

struct DefaultThemeOGColor: ThemeOGColor {

    var tint: UIColor {
        UIColor.tintPrimary
    }

    var tintLight: UIColor {
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

    var text: UIColor {
        UIColor.textColor
    }

    var textSecondary: UIColor {
        UIColor.textColorSecondary
    }

    var textTertiary: UIColor {
        UIColor.textColorTertiary
    }

    var red: UIColor {
        UIColor.appRed
    }

    var green: UIColor {
        UIColor.appGreen
    }
}
