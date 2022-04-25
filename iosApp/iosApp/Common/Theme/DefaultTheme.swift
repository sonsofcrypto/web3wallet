//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

struct DefaultTheme: ThemeProvider {

    private(set) var color: ThemeColor = DefaultTheme.Color()
    private(set) var font: ThemeFont = DefaultTheme.Font()
    private(set) var attributes: ThemeAttributes = DefaultTheme.Attributes()
}

// MARK: - Color

extension DefaultTheme {

    struct Color: ThemeColor {

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
}

// MARK: - Font

extension DefaultTheme {

    struct Font: ThemeFont {
        var body: UIFont {
            UIFont.font(.gothicA1, style: .regular, size: .body)
        }

        var navTitle: UIFont {
            UIFont.font(.nothingYouCouldDo, style: .regular, size: .custom(size: 24))
        }

        var title1: UIFont {
            UIFont.font(.gothicA1, style: .bold, size: .title1)
        }

        var callout: UIFont {
            UIFont.font(.gothicA1, style: .regular, size: .callout)
        }

        var headline: UIFont {
            UIFont.font(.gothicA1, style: .regular, size: .headline)
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

        var caption1: UIFont {
            UIFont.font(.gothicA1, style: .regular, size: .caption1)
        }

        var caption2: UIFont {
            UIFont.font(.gothicA1, style: .regular, size: .caption2)
        }

        var tabBar: UIFont {
            UIFont.font(.gothicA1, style: .medium, size: .custom(size: 10))
        }

        var cellDetail: UIFont {
            UIFont.font(.gothicA1, style: .regular, size: .custom(size: 15))
        }
    }
}

// MARK: - Attributes

extension DefaultTheme {

    struct Attributes: ThemeAttributes {

        func body() -> [NSAttributedString.Key: Any] {
            [
                .font: Theme.font.body,
                .foregroundColor: Theme.color.text,
                .shadow: textShadow(Theme.current.color.tintSecondary)
            ]
        }

        func placeholder() -> [NSAttributedString.Key: Any] {
            [
                .font: Theme.font.subhead,
                .foregroundColor: Theme.color.textTertiary,
            ]
        }

        func sectionFooter() -> [NSAttributedString.Key: Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6

            return [
                .font: Theme.font.cellDetail,
                .foregroundColor: Theme.color.textTertiary,
                .paragraphStyle: paragraphStyle
            ]
        }

        func textShadow(_ tint: UIColor) -> NSShadow {
            let shadow = NSShadow()
            shadow.shadowOffset = .zero
            shadow.shadowBlurRadius = Global.shadowRadius
            shadow.shadowColor = tint
            return shadow
        }
    }
}
