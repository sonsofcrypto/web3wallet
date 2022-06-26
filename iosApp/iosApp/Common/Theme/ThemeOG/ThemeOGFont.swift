// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol ThemeOGFont {
    
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

struct DefaultThemeOGFont: ThemeOGFont {
    
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
