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

    var tint: UIColor { get }
    var tintLight: UIColor { get }
    var tintSecondary: UIColor { get }
    var background: UIColor { get }
    var backgroundDark: UIColor { get }
    var text: UIColor { get }
    var textSecondary: UIColor { get }
    var textTertiary: UIColor { get }
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

    func body() -> [NSAttributedString.Key: Any]
    func placeholder() -> [NSAttributedString.Key: Any]
    func sectionFooter() -> [NSAttributedString.Key: Any]
    func textShadow(_ tint: UIColor) -> NSShadow
}

struct Theme {

    private static var current: ThemeProvider = DefaultTheme()
    
//    var color: ThemeColor = Theme.color
//    var font: ThemeFont = Theme.font
//    var attributes: ThemeAttributes = Theme.attributes
    
    static var color: ThemeColor {
        Theme.current.color
    }

    static var font: ThemeFont {
        Theme.current.font
    }

    static var attributes: ThemeAttributes {
        Theme.current.attributes
    }
}
