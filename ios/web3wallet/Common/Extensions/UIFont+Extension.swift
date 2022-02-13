// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIFont {

    static func font(_ font: Font, style: Style = .regular, size: Size = .body) -> UIFont {
        if let font = UIFont(
            name: "\(font.rawValue) \(style.rawValue)",
            size: size.size()
        ) {
            return font
        }

        if let font = UIFont(
            name: "\(font.rawValue) \(Style.regular.rawValue)",
            size: size.size()
        ) {
            return font
        }

        if let font = UIFont(name: "\(font.rawValue)", size: size.size()) {
            return font
        }

        return UIFont.systemFont(ofSize: size.size(), weight: style.systemWeight())
    }

    enum Font: String {
        case gothicA1 = "Gothic A1"
        case nothingYouCouldDo = "Nothing You Could Do"
    }

    enum Style: String {
        case thin = "Thin"
        case extraLight = "ExtraLight"
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case bold = "Bold"
        case extraBold = "ExtraBold"
        case black = "Black"

        func systemWeight() -> UIFont.Weight {
            switch self {
                case .thin: return .thin
                case .extraLight: return .ultraLight
                case .light: return .light
                case .regular: return .regular
                case .medium: return .medium
                case .semiBold: return .semibold
                case .bold: return .bold
                case .extraBold: return .heavy
                case .black: return .black
            }
        }
    }

    enum Size {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case body
        case callout
        case subhead
        case footnote
        case caption1
        case caption2
        case custom(size: CGFloat)

        func size() -> CGFloat {
            switch self {
            case .largeTitle: return 34
            case .title1: return 28
            case .title2: return 22
            case .title3: return 20
            case .headline: return 18
            case .body: return 17
            case .callout: return 16
            case .subhead: return 15
            case .footnote: return 13
            case .caption1: return 12
            case .caption2: return 11
            case let .custom(size): return size
            }
        }
    }
}
