//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

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
        case smallLabel
        case smallerLabel
        case smallestLabel
        case smallestLabelGlow
        case smallBody
    }

    func applyStyle(_ style: Style) {
        switch style {
        case .headlineGlow:
            font = AppTheme.current.fonts.headline
            layer.applyShadow(AppTheme.current.colors.tintSecondary)
            textColor = AppTheme.current.colors.textColor
        case .callout:
            font = AppTheme.current.fonts.callout
            layer.applyShadow(AppTheme.current.colors.tintSecondary)
            textColor = AppTheme.current.colors.textColor
        case .subhead:
            font = AppTheme.current.fonts.subhead
            textColor = AppTheme.current.colors.textColorSecondary
        case .subheadGlow:
            font = AppTheme.current.fonts.subhead
            layer.applyShadow(AppTheme.current.colors.tintSecondary)
            textColor = AppTheme.current.colors.textColor
        case.smallLabel:
            font = AppTheme.current.fonts.footnote
            textColor = AppTheme.current.colors.textColorTertiary
        case.smallerLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption1)
            textColor = AppTheme.current.colors.textColorSecondary
        case.smallestLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
            textColor = AppTheme.current.colors.textColorTertiary
        case.smallestLabelGlow:
            layer.applyShadow(
                AppTheme.current.colors.tintSecondary,
                radius: Global.shadowRadius / 2
            )
            font = AppTheme.current.fonts.caption2
            textColor = AppTheme.current.colors.tintSecondary
        case .smallBody:
            font = AppTheme.current.fonts.footnote
            textColor = AppTheme.current.colors.textColorSecondary
        }
    }
}
