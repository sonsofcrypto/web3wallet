// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIView {

    class func springAnimate(
        _ duration: TimeInterval = 0.5,
        delay: TimeInterval = 0,
        damping: CGFloat = 0.85,
        velocity: CGFloat = 0.95,
        options: UIView.AnimationOptions = [
            .allowUserInteraction,
            .allowAnimatedContent,
            .beginFromCurrentState
        ],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            animations: animations,
            completion: completion
        )
    }
}