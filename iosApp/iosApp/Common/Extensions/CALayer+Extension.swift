// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension CALayer {

    func applyShadow(
        _ color: UIColor = Theme.color.collectionSectionStroke,
        radius: CGFloat = Theme.cornerRadius.half.half
    ) {
        shadowColor = color.cgColor
        shadowRadius = radius
        shadowOffset = .zero
        shadowOpacity = 1
        masksToBounds = false
    }

    func applyRectShadow(
        _ color: UIColor = Theme.color.collectionSectionStroke,
        radius: CGFloat = Theme.cornerRadius.half.half,
        cornerRadius: CGFloat = Theme.cornerRadius.half
    ) {
        applyShadowPath(bounds, radius: cornerRadius)
        applyShadow(color, radius: radius)
    }

    func applyBorder(_ color: UIColor = Theme.color.collectionSectionStroke) {
        borderWidth = 1
        borderColor = color.cgColor
    }

    func applyShadowPath(
        _ bounds: CGRect,
        radius: CGFloat = Theme.cornerRadius.half
    ) {
        cornerRadius = radius
        shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radius
        ).cgPath
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

extension CATransform3D {

    static func m34(_ m34:CGFloat = -1.0 / 500.0) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = m34
        return transform
    }
}