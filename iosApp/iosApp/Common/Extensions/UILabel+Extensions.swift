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
            font = Theme.font.navTitle
            textColor = Theme.color.tint
        case .headlineGlow:
            font = Theme.font.headline
            layer.applyShadow(Theme.color.tintSecondary)
            textColor = Theme.color.text
        case .callout:
            font = Theme.font.callout
            layer.applyShadow(Theme.color.tintSecondary)
            textColor = Theme.color.text
            update(lineSpacing: 6)
        case .subhead:
            font = Theme.font.subhead
            textColor = Theme.color.textSecondary
        case .subheadGlow:
            font = Theme.font.subhead
            layer.applyShadow(Theme.color.tintSecondary)
            textColor = Theme.color.text
            font = Theme.font.subhead
            layer.applyShadow(Theme.color.tintSecondary)
            textColor = Theme.color.text
        case .body:
            font = Theme.font.body
            textColor = Theme.color.text
            update(lineSpacing: 8)
        case .bodyGlow:
            font = Theme.font.body
            layer.applyShadow(Theme.color.tintSecondary)
            textColor = Theme.color.text
        case.smallLabel:
            font = Theme.font.footnote
            textColor = Theme.color.textTertiary
        case.smallerLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption1)
            textColor = Theme.color.textSecondary
        case.smallestLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
            textColor = Theme.color.textTertiary
        case.smallestLabelGlow:
            layer.applyShadow(
                Theme.color.tintSecondary,
                radius: Global.shadowRadius / 2
            )
            font = Theme.font.caption2
            textColor = Theme.color.tintSecondary
        case .smallBody:
            font = Theme.font.footnote
            textColor = Theme.color.textSecondary
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
