// Created by web3d3v on 05/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UITextView {

    convenience init(with style: Style) {
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
            textColor = Theme.color.textPrimary
        case .headlineGlow:
            font = Theme.font.headline
//            layer.applyShadow(Theme.color.fillSecondary)
            textColor = Theme.color.textPrimary
        case .callout:
            font = Theme.font.callout
            textColor = Theme.color.textPrimary
            update(lineSpacing: 6)
        case .subhead:
            font = Theme.font.subheadline
            textColor = Theme.color.textSecondary
        case .subheadGlow:
            font = Theme.font.subheadline
//            layer.applyShadow(Theme.color.fillSecondary)
            textColor = Theme.color.textPrimary
            font = Theme.font.subheadline
//            layer.applyShadow(Theme.color.fillSecondary)
            textColor = Theme.color.textPrimary
        case .body:
            font = Theme.font.subheadline
            textColor = Theme.color.textPrimary
            update(lineSpacing: 8)
        case .bodyGlow:
            font = Theme.font.body
//            layer.applyShadow(Theme.color.fillSecondary)
            textColor = Theme.color.textPrimary
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
//            layer.applyShadow(
//                Theme.color.fillSecondary,
//                radius: Theme.cornerRadiusSmall.half / 2
//            )
            font = Theme.font.caption2
//            textColor = Theme.color.fillSecondary
        case .smallBody:
            font = Theme.font.footnote
            textColor = Theme.color.textSecondary
        }
    }
}

extension UITextView {
    
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
