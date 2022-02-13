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
        UIColor.white
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
}

