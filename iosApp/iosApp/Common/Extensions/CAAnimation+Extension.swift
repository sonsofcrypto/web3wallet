// Created by web3d3v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension CAAnimation {

    static func buildUp(_ delay: Double = 0) -> CABasicAnimation {
        let rotation = CATransform3DMakeRotation(-3.13 / 2, 1, 0, 0)
        let anim = CABasicAnimation(keyPath: "transform")
        anim.fromValue = CATransform3DScale(rotation, 0.5, 0.5, 0)
        anim.toValue = CATransform3DIdentity
        anim.duration = 0.3
        anim.isRemovedOnCompletion = true
        anim.fillMode = .both
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.beginTime = CACurrentMediaTime() + CGFloat(delay);
        return anim
    }
}
