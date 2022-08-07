// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension CALayer {

    func applyShadow(
        _ color: UIColor = Theme.colour.fillPrimary,
        radius: CGFloat = Theme.constant.cornerRadiusSmall.half
    ) {
        shadowColor = color.cgColor
        shadowRadius = radius
        shadowOffset = .zero
        shadowOpacity = 1
        masksToBounds = false
    }

    func applyRectShadow(
        _ color: UIColor = Theme.colour.fillPrimary,
        radius: CGFloat = Theme.constant.cornerRadiusSmall.half,
        cornerRadius: CGFloat = Theme.constant.cornerRadiusSmall
    ) {
        applyShadowPath(bounds, radius: cornerRadius)
        applyShadow(color, radius: radius)
    }

    func applyBorder(_ color: UIColor = Theme.colour.fillPrimary) {
        borderWidth = 1
        borderColor = color.cgColor
    }

    func applyShadowPath(_ bounds: CGRect, radius: CGFloat = Theme.constant.cornerRadiusSmall) {
        cornerRadius = radius
        shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radius
        ).cgPath
    }
}

extension CALayer {

    func applyHighlighted(_ highlighted: Bool) {
        // TODO: @Annon discussion
        borderColor = (highlighted
            ? Theme.colour.fillPrimary
            : Theme.colour.fillPrimary
        ).cgColor
        shadowOpacity = highlighted ? 1 : 0
    }
}

extension CACornerMask {

    static var all: CACornerMask {
        [
            layerMinXMinYCorner,
            layerMinXMaxYCorner,
            layerMaxXMinYCorner,
            layerMaxXMaxYCorner
        ]
    }
}