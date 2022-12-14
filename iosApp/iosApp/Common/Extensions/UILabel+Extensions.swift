// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UILabel {

    convenience init(
        with style: UILabel.Style,
        weight: UILabel.Weight = .regular,
        colour: UIColor = Theme.color.textPrimary
    ) {
        self.init()
        apply(
            style: style,
            weight: weight,
            colour: colour
        )
    }

    enum Style {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case caption1
        case caption2
        case footnote
        case navTitle
        case tabBar
        case networkTitle
        case dashboardSectionFuel
        case dashboardTVBalance
        case dashboardTVSymbol
        case dashboardTVPct
        case dashboardTVTokenBalance
    }
    
    enum Weight {
        case regular
        case bold
    }

    func apply(
        style: Style,
        weight: UILabel.Weight = .regular,
        colour: UIColor = Theme.color.textPrimary
    ) {
        
        switch style {
            
        case .largeTitle:
            switch weight {
            case .regular:
                font = Theme.font.largeTitle
            case .bold:
                font = Theme.font.largeTitleBold
            }
        case .title1:
            switch weight {
            case .regular:
                font = Theme.font.title1
            case .bold:
                font = Theme.font.title1Bold
            }
            
        case .title2:
            switch weight {
            case .regular:
                font = Theme.font.title2
            case .bold:
                font = Theme.font.title2Bold
            }
            
        case .title3:
            switch weight {
            case .regular:
                font = Theme.font.title3
            case .bold:
                font = Theme.font.title3Bold
            }
            
        case .headline:
            switch weight {
            case .regular:
                font = Theme.font.headline
            case .bold:
                font = Theme.font.headlineBold
            }
            
        case .subheadline:
            switch weight {
            case .regular:
                font = Theme.font.subheadline
            case .bold:
                font = Theme.font.subheadlineBold
            }
            
        case .body:
            switch weight {
            case .regular:
                font = Theme.font.body
            case .bold:
                font = Theme.font.bodyBold
            }
            
        case .callout:
            switch weight {
            case .regular:
                font = Theme.font.callout
            case .bold:
                font = Theme.font.calloutBold
            }
            
        case .caption1:
            switch weight {
            case .regular:
                font = Theme.font.caption1
            case .bold:
                font = Theme.font.caption1Bold
            }
            
        case .caption2:
            switch weight {
            case .regular:
                font = Theme.font.caption2
            case .bold:
                font = Theme.font.caption2Bold
            }
            
        case .footnote:
            switch weight {
            case .regular:
                font = Theme.font.footnote
            case .bold:
                font = Theme.font.footnoteBold
            }
            
        case .navTitle:
            font = Theme.font.navTitle
            textColor = Theme.color.navBarTitle
            
        case .tabBar:
            font = Theme.font.tabBar
            
        case .networkTitle:
            font = Theme.font.networkTitle
            
        case .dashboardSectionFuel:
            font = Theme.font.dashboardSectionFuel
            
        case .dashboardTVBalance:
            font = Theme.font.dashboardTVBalance
            
        case .dashboardTVSymbol:
            font = Theme.font.dashboardTVSymbol
            
        case .dashboardTVPct:
            font = Theme.font.dashboardTVPct
            
        case .dashboardTVTokenBalance:
            font = Theme.font.dashboardTVTokenBalance
            
        }
        
        textColor = colour
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

extension UILabel {

    convenience init(
        _ font: UIFont? = nil,
        color: UIColor? = nil,
        text: String? = nil
    ) {
        self.init()
        if let font = font {
            self.font = font
        }
        if let color = color {
            self.textColor = color
        }
        if let text = text {
            self.text = text
        }
    }
}