//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol ThemeProvider {

    var color: ThemeColor { get }
    var font: ThemeFont { get }
    var attributes: ThemeAttributes { get }
}

protocol ThemeColor {

    var tintPrimary: UIColor { get }
    var tintPrimaryLight: UIColor { get }
    var tintSecondary: UIColor { get }
    var background: UIColor { get }
    var backgroundDark: UIColor { get }
    var textColor: UIColor { get }
    var textColorSecondary: UIColor { get }
    var textColorTertiary: UIColor { get }
    var red: UIColor { get }
    var green: UIColor { get }
}

protocol ThemeFont {
    var body: UIFont { get }
    var navTitle: UIFont { get }
    var title1: UIFont { get }
    var callout: UIFont { get }
    var headline: UIFont { get }
    var subhead: UIFont { get }
    var mediumButton: UIFont { get }
    var hugeBalance: UIFont { get }
    var footnote: UIFont { get }
    var caption1: UIFont { get }
    var caption2: UIFont { get }
    var tabBar: UIFont { get }
    var cellDetail: UIFont { get }
}

protocol ThemeAttributes {

    func bodyTextAttributes() -> [NSAttributedString.Key: Any]
    func placeholderTextAttributes() -> [NSAttributedString.Key: Any]
    func sectionFooterTextAttributes() -> [NSAttributedString.Key: Any]
    func textShadow(_ tint: UIColor = ThemeOld.current.tintSecondary ) -> NSShadow
}

struct Theme: ThemeProvider {

    static var current: ThemeProvider = DefaultTheme()

    private(set) var color: ThemeColor {
        Theme.current.color
    }

    private(set) var font: ThemeFont {
        Theme.current.font
    }

    private(set) var attributes: ThemeAttributes {
        Theme.current.attributes
    }
}
