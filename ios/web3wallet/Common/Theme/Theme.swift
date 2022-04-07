//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol Theme {
    
    var colors: Colors { get }
    var fonts: Fonts { get }
}

protocol Colors {
    
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

protocol Fonts {
    
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
