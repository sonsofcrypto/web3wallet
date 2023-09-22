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
            .beginFromCurrentState,
        ],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: completion
        )
    }

    class func animateKeyframes(
        _ duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.KeyframeAnimationOptions = [],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        animateKeyframes(
            withDuration: duration,
            delay: delay,
            options: options,
            animations: animations,
            completion: completion
        )
    }

    class func addKeyframe(
        _ start: Double,
        duration: Double,
        animations: @escaping () -> Void
    ) {
        addKeyframe(
            withRelativeStartTime: start,
            relativeDuration: duration,
            animations: animations
        )
    }

    func shakeAnimate() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [0, -20, 20, -20, 20, -10, 10, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
}

extension UIView {
    
    func removeAllSubview() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Layout

extension UIView {

    func contraintToSuperView(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) {
        guard let sv = superview else { return }

        sv.addConstraints([
            leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: left),
            trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: right),
            topAnchor.constraint(equalTo: sv.topAnchor, constant: top),
            bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: bottom),
        ])
    }
}