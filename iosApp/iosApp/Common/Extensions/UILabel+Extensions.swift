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
            textColor = Theme.colour.fillPrimary
        case .headlineGlow:
            font = Theme.font.headline
            layer.applyShadow(Theme.colour.fillSecondary)
            textColor = Theme.colour.labelPrimary
        case .callout:
            font = Theme.font.callout
            layer.applyShadow(Theme.colour.fillSecondary)
            textColor = Theme.colour.labelPrimary
            update(lineSpacing: 6)
        case .subhead:
            font = Theme.font.subheadline
            textColor = Theme.colour.labelSecondary
        case .subheadGlow:
            font = Theme.font.subheadline
            layer.applyShadow(Theme.colour.fillSecondary)
            textColor = Theme.colour.labelPrimary
            font = Theme.font.subheadline
            layer.applyShadow(Theme.colour.fillSecondary)
            textColor = Theme.colour.labelPrimary
        case .body:
            font = Theme.font.body
            textColor = Theme.colour.labelPrimary
            update(lineSpacing: 8)
        case .bodyGlow:
            font = Theme.font.body
            layer.applyShadow(Theme.colour.fillSecondary)
            textColor = Theme.colour.labelPrimary
        case.smallLabel:
            font = Theme.font.footnote
            textColor = Theme.colour.labelTertiary
        case.smallerLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption1)
            textColor = Theme.colour.labelSecondary
        case.smallestLabel:
            font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
            textColor = Theme.colour.labelTertiary
        case.smallestLabelGlow:
            layer.applyShadow(
                Theme.colour.fillSecondary,
                radius: Global.shadowRadius / 2
            )
            font = Theme.font.caption2
            textColor = Theme.colour.fillSecondary
        case .smallBody:
            font = Theme.font.footnote
            textColor = Theme.colour.labelSecondary
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
