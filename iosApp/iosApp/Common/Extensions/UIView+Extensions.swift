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

extension UIView {

    func animateCopyToPasteboard(_ text: String? = nil, maxLines: Int = 0) {
        let ty = bounds.height
        let blur = ThemeBlurView().round()
        blur.frame = bounds
        blur.transform = CGAffineTransformMakeTranslation(bounds.width, 0)
        addSubview(blur)

        let attrStr = NSMutableAttributedString(string: "")
        let imgAttachment = NSTextAttachment()
        imgAttachment.image = UIImage(systemName: "square.on.square")?
            .withTintColor(Theme.color.textPrimary)
        attrStr.append(NSAttributedString(attachment: imgAttachment))
        attrStr.append(
            NSAttributedString(string: " " + Localized("copiedToPasteboard"))
        )

        if let text = text {
            attrStr.append(NSAttributedString(string: "\n" + text))
        }

        let label = UILabel(color: Theme.color.textPrimary)
        label.numberOfLines = maxLines
        label.attributedText = attrStr
        blur.contentView.addSubview(label)
        label.frame = CGRect(center: blur.bounds.midXY, size: blur.bounds.size)
            .insetBy(dx: Theme.paddingHalf, dy: Theme.paddingHalf)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        UIView.springAnimate(
            animations: { blur.transform = .identity },
            completion: { _ in
                UIView.springAnimate(
                    delay: 2,
                    animations: {
                        blur.transform = CGAffineTransformMakeTranslation(0, ty)
                        blur.alpha = 0
                    },
                    completion: { _ in blur.removeFromSuperview() }
                )
            })
    }
}

extension UIView {

    func rounded(_ radius: CGFloat = Theme.cornerRadius) -> Self {
        layer.cornerRadius = radius
        layer.maskedCorners = .all
        clipsToBounds = true
        return self 
    }

}
