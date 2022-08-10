// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIView {
    
    var isDarkMode: Bool {
        
        UITraitCollection.current.userInterfaceStyle == .dark
    }
}

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

extension UIView {
    
    class func vSpace(
        height: CGFloat = Theme.constant.padding
    ) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: height))
            ]
        )
        
        return view
    }
    
    class func hSpace(
        value: CGFloat = Theme.constant.padding
    ) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: value))
            ]
        )
        
        return view
    }
    
    class func dividerLine(
        backgroundColor: UIColor = Theme.colour.separatorTransparent,
        height: CGFloat = 1
    ) -> UIView {
        
        let view = UIView()
        view.backgroundColor = backgroundColor
        view.addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: height))
            ]
        )
        
        return view
    }
}
