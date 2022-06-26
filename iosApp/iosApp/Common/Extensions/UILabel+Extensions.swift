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
            font = ThemeOG.font.navTitle
            textColor = ThemeOG.color.tint
        case .headlineGlow:
            font = ThemeOG.font.headline
            layer.applyShadow(ThemeOG.color.tintSecondary)
            textColor = ThemeOG.color.text
        case .callout:
            font = ThemeOG.font.callout
            layer.applyShadow(ThemeOG.color.tintSecondary)
            textColor = ThemeOG.color.text
            update(lineSpacing: 6)
        case .subhead:
            font = ThemeOG.font.subhead
            textColor = ThemeOG.color.textSecondary
        case .subheadGlow:
            font = ThemeOG.font.subhead
            layer.applyShadow(ThemeOG.color.tintSecondary)
            textColor = ThemeOG.color.text
            font = ThemeOG.font.subhead
            layer.applyShadow(ThemeOG.color.tintSecondary)
            textColor = ThemeOG.color.text
        case .body:
            font = ThemeOG.font.body
            textColor = ThemeOG.color.text
            update(lineSpacing: 8)
        case .bodyGlow:
            font = ThemeOG.font.body
            layer.applyShadow(ThemeOG.color.tintSecondary)
            textColor = ThemeOG.color.text
        case.smallLabel:
            font = ThemeOG.font.footnote
            textColor = ThemeOG.color.textTertiary
        case.smallerLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption1)
            textColor = ThemeOG.color.textSecondary
        case.smallestLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
            textColor = ThemeOG.color.textTertiary
        case.smallestLabelGlow:
            layer.applyShadow(
                ThemeOG.color.tintSecondary,
                radius: Global.shadowRadius / 2
            )
            font = ThemeOG.font.caption2
            textColor = ThemeOG.color.tintSecondary
        case .smallBody:
            font = ThemeOG.font.footnote
            textColor = ThemeOG.color.textSecondary
        }
    }
}

private extension UILabel {
    
    func update(
        lineSpacing: CGFloat = 10
    ) {
        
        let attrString = NSMutableAttributedString(string: text ?? "")
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        attrString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: style,
            range: NSRange(location: 0, length: attrString.length)
        )
        attributedText = attrString
    }
}
