// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UILabel {

    convenience init(with style: UILabel.Style) {
        self.init()
        self.applyStyle(style)
    }

    enum Style {
        case headlineGlow
        case callout
        case subhead
        case subheadGlow
        case bodyGlow
        case smallLabel
        case smallerLabel
        case smallestLabel
        case smallestLabelGlow
        case smallBody
    }

    func applyStyle(_ style: Style) {
        switch style {
        case .headlineGlow:
            font = ThemeOld.current.headline
            layer.applyShadow(ThemeOld.current.tintSecondary)
            textColor = ThemeOld.current.textColor
        case .callout:
            font = ThemeOld.current.callout
            layer.applyShadow(ThemeOld.current.tintSecondary)
            textColor = ThemeOld.current.textColor
        case .subhead:
            font = ThemeOld.current.subhead
            textColor = ThemeOld.current.textColorSecondary
        case .subheadGlow:
            font = ThemeOld.current.subhead
            layer.applyShadow(ThemeOld.current.tintSecondary)
            textColor = ThemeOld.current.textColor
        case .bodyGlow:
            font = ThemeOld.current.body
            layer.applyShadow(ThemeOld.current.tintSecondary)
            textColor = ThemeOld.current.textColor
        case.smallLabel:
            font = ThemeOld.current.footnote
            textColor = ThemeOld.current.textColorTertiary
        case.smallerLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption1)
            textColor = ThemeOld.current.textColorSecondary
        case.smallestLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
            textColor = ThemeOld.current.textColorTertiary
        case.smallestLabelGlow:
            layer.applyShadow(
                ThemeOld.current.tintSecondary,
                radius: Global.shadowRadius / 2
            )
            font = ThemeOld.current.caption2
            textColor = ThemeOld.current.tintSecondary
        case .smallBody:
            font = ThemeOld.current.footnote
            textColor = ThemeOld.current.textColorSecondary
        }
    }
}
