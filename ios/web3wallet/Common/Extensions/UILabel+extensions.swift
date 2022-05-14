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
        case navTitle
        case headlineGlow
        case callout
        case subhead
        case subheadGlow
        case body
        case bodyGlow
        case smallLabel
        case smallerLabel
        case smallestLabel
        case smallestLabelGlow
        case smallBody
    }

    func applyStyle(_ style: Style) {
        switch style {
        case .navTitle:
            font = Theme.current.navTitle
            textColor = Theme.current.tintPrimary
        case .headlineGlow:
            font = Theme.current.headline
            layer.applyShadow(Theme.current.tintSecondary)
            textColor = Theme.current.textColor
        case .callout:
            font = Theme.current.callout
            layer.applyShadow(Theme.current.tintSecondary)
            textColor = Theme.current.textColor
        case .subhead:
            font = Theme.current.subhead
            textColor = Theme.current.textColorSecondary
        case .subheadGlow:
            font = Theme.current.subhead
            layer.applyShadow(Theme.current.tintSecondary)
            textColor = Theme.current.textColor
        case .body:
            font = Theme.current.body
            textColor = Theme.current.textColor
        case .bodyGlow:
            font = Theme.current.body
            layer.applyShadow(Theme.current.tintSecondary)
            textColor = Theme.current.textColor
        case.smallLabel:
            font = Theme.current.footnote
            textColor = Theme.current.textColorTertiary
        case.smallerLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption1)
            textColor = Theme.current.textColorSecondary
        case.smallestLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
            textColor = Theme.current.textColorTertiary
        case.smallestLabelGlow:
            layer.applyShadow(
                Theme.current.tintSecondary,
                radius: Global.shadowRadius / 2
            )
            font = Theme.current.caption2
            textColor = Theme.current.tintSecondary
        case .smallBody:
            font = Theme.current.footnote
            textColor = Theme.current.textColorSecondary
        }
    }
}
