// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension CALayer {

    func applyShadow(
        _ color: UIColor = Theme.current.tintPrimary,
        radius: CGFloat = Global.shadowRadius
    ) {
        shadowColor = color.cgColor
        shadowRadius = radius
        shadowOffset = .zero
        shadowOpacity = 1
        masksToBounds = false
    }

    func applyRectShadow(
        _ color: UIColor = Theme.current.tintPrimary,
        radius: CGFloat = Global.shadowRadius,
        cornerRadius: CGFloat = Global.cornerRadius
    ) {
        applyShadow(color, radius: radius)
        shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }

    func applyStroke(_ color: UIColor = Theme.current.tintPrimary) {
        borderWidth = 1
        borderColor = color.cgColor
    }
}