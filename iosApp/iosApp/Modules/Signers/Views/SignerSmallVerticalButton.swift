// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

@IBDesignable
class SignerSmallVerticalButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let label = titleLabel, !label.isHidden else {
            imageView?.center = bounds.midXY
            return
        }

        imageView?.center.y = bounds.height * 0.333
        label.bounds.size = label.sizeThatFits(.init(width: 100, height: 20))
        label.center = .init(x: bounds.midX, y: bounds.maxY - label.bounds.midY)
    }

    override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize
        return .init(width: 39, height: 42)
    }
}
