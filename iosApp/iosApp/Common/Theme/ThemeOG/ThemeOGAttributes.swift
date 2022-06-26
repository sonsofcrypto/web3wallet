// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol ThemeOGAttributes {

    func body() -> [NSAttributedString.Key: Any]
    func placeholder() -> [NSAttributedString.Key: Any]
    func sectionFooter() -> [NSAttributedString.Key: Any]
    func textShadow(_ tint: UIColor) -> NSShadow
}

struct DefaultThemeOGAttributes: ThemeOGAttributes {

    func body() -> [NSAttributedString.Key: Any] {
        [
            .font: ThemeOG.font.body,
            .foregroundColor: ThemeOG.color.text,
            .shadow: textShadow(ThemeOG.color.tintSecondary)
        ]
    }

    func placeholder() -> [NSAttributedString.Key: Any] {
        [
            .font: ThemeOG.font.subhead,
            .foregroundColor: ThemeOG.color.textTertiary,
        ]
    }

    func sectionFooter() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        return [
            .font: ThemeOG.font.cellDetail,
            .foregroundColor: ThemeOG.color.textTertiary,
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
