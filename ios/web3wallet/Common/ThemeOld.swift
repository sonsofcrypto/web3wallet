// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct ThemeOld {

    static var current: ThemeOld = ThemeOld()

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
        UIColor.textColor
    }

    var textColorSecondary: UIColor {
        UIColor.textColorSecondary
    }

    var textColorTertiary: UIColor {
        UIColor.textColorTertiary
    }

    var red: UIColor {
        UIColor.appRed
    }

    var green: UIColor {
        UIColor.appGreen
    }


    // MARK: - Fonts

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

    func bodyTextAttributes() -> [NSAttributedString.Key: Any] {
        [
            .font: ThemeOld.current.body,
            .foregroundColor: ThemeOld.current.textColor,
            .shadow: textShadow()
        ]
    }

    func placeholderTextAttributes() -> [NSAttributedString.Key: Any] {
        [
            .font: ThemeOld.current.subhead,
            .foregroundColor: ThemeOld.current.textColorTertiary,
        ]
    }

    func sectionFooterTextAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        return [
            .font: ThemeOld.current.cellDetail,
            .foregroundColor: ThemeOld.current.textColorTertiary,
            .paragraphStyle: paragraphStyle
        ]
    }

    func textShadow(_ tint: UIColor = ThemeOld.current.tintSecondary ) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Global.shadowRadius
        shadow.shadowColor = tint
        return shadow
    }
}

