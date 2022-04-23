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
}

extension UIView {
    
    class func vSpace(
        height: CGFloat = 16
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
    
    class func dividerLine(
        backgorundColor: UIColor = Theme.current.red,
        height: CGFloat = 1
    ) -> UIView {
        
        let view = UIView()
        view.backgroundColor = backgorundColor
        view.addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: height))
            ]
        )
        
        return view
    }
}
