// Created by web3d3v on 21/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CardFlipAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {

    var targetView: UIView
    var isPresenting: Bool
    var scaleAdjustment: CGFloat = 0

    private var handler: (()->Void)? = nil

    init(
        targetView: UIView,
        isPresenting: Bool = true,
        scaleAdjustment: CGFloat = 0,
        handler: (()->Void)? = nil
    ) {
        self.targetView = targetView
        self.isPresenting = isPresenting
        self.scaleAdjustment = scaleAdjustment
        self.handler = handler
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 0.7 : 0.9
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVc = transitionContext.viewController(forKey: .from)
        let toVc = transitionContext.viewController(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView

        containerView.layer.sublayerTransform = CATransform3D.m34()

        if isPresenting {
            animatePresenting(
                fromVc: fromVc,
                toVc: toVc,
                fromView: targetView,
                toView: toView ?? toVc?.view,
                containerView: containerView,
                context: transitionContext
            )
        } else {
            animateDismissing(
                fromVc: fromVc,
                toVc: toVc,
                fromView: fromView ?? fromVc?.view,
                toView: targetView,
                containerView: containerView,
                context: transitionContext
            )
        }
    }

    func animatePresenting(
        fromVc: UIViewController?,
        toVc: UIViewController?,
        fromView: UIView?,
        toView: UIView?,
        containerView: UIView,
        context: UIViewControllerContextTransitioning
    ) {

        let transformView = TransformView(frame: containerView.bounds)
        let snap = fromView?.snapshotView(afterScreenUpdates: false)
        var snapScale: CGSize = .zero
        var translation: CGPoint = .zero

        if let toView = toView, let fromView = fromView, let snap = snap {
            transformView.frame = containerView.bounds
            toView.frame = transformView.bounds

            snapScale = CGSize(
                width: toView.bounds.width / snap.bounds.width,
                height: toView.bounds.height / snap.bounds.height
            )

            translation = CGPoint(
                x: containerView.convert(fromView.bounds.midXY, from: fromView).x - toView.center.x,
                y: containerView.convert(fromView.bounds.midXY, from: fromView).y - toView.center.y
            )

            containerView.addSubview(transformView)
            transformView.addSubview(toView)
            transformView.addSubview(snap)

            toView.layer.zPosition = -1
            toView.transform = CGAffineTransform(
                scaleX: -(snap.bounds.width / toView.bounds.width),
                y: snap.bounds.height / toView.bounds.height
            )

            [toView, snap].forEach { $0.center = transformView.bounds.midXY }
        }

        containerView.layer.sublayerTransform = TransformView.parentSublayerTransform
        transformView.layer.transform = CATransform3DMakeTranslation(
            translation.x,
            translation.y,
            0
        )

        let angle = CGFloat(-Double.pi) + 0.001
        fromView?.alpha = 0.0001
        toView?.alpha = 0
        toView?.layer.cornerRadius = (fromView?.layer.cornerRadius
            ?? Theme.padding) * 4

        UIView.animateKeyframes(transitionDuration(using: context), animations: {
            UIView.addKeyframe(0, duration: 0.04) { toView?.alpha = 0 }
            UIView.addKeyframe(0.04, duration: 0.1) { toView?.alpha = 1 }
            UIView.addKeyframe(0.14, duration: 0.86) { toView?.alpha = 1 }
        })

        UIView.springAnimate(
            transitionDuration(using: context),
            damping: 0.9,
            velocity: 0.6,
            animations: {
                transformView.layer.transform = CATransform3DMakeRotation(angle, 0, 1, 0)
                toView?.layer.cornerRadius = 0
                toView?.transform = CGAffineTransform(scaleX: -1, y: 1)
                snap?.transform = CGAffineTransform(
                    scaleX: snapScale.width,
                    y: snapScale.height
                )
            },
            completion: { [weak self] success in
                snap?.removeFromSuperview()
                transformView.removeFromSuperview()
                fromView?.alpha = 1
                if let toView = toView {
                    toView.layer.zPosition = 0
                    toView.transform = .identity
                    toView.frame = containerView.bounds
                    containerView.addSubview(toView)
                }
                context.completeTransition(success)
                self?.handler?()
            }
        )
    }

    func animateDismissing(
        fromVc: UIViewController?,
        toVc: UIViewController?,
        fromView: UIView?,
        toView: UIView?,
        containerView: UIView,
        context: UIViewControllerContextTransitioning
    ) {
        let transformView = TransformView(frame: containerView.bounds)
        let snap = toView?.snapshotView(afterScreenUpdates: false)
        var snapScale: CGSize = .zero
        var translation: CGPoint = .zero

        if let toView = toView, let fromView = fromView, let snap = snap {
            transformView.frame = containerView.bounds
            fromView.frame = transformView.bounds

            snapScale = CGSize(
                width: toView.bounds.width / fromView.bounds.width,
                height: toView.bounds.height / fromView.bounds.height
            )

            translation = CGPoint(
                x: -(containerView.convert(toView.bounds.midXY, from: toView).x - fromView.center.x),
                y: containerView.convert(toView.bounds.midXY, from: toView).y - fromView.center.y
            )

            containerView.addSubview(transformView)
            transformView.addSubview(snap)
            transformView.addSubview(fromView)

            snap.layer.zPosition = -1
            snap.transform = CGAffineTransform(
                scaleX: -(fromView.bounds.width / snap.bounds.width),
                y: fromView.bounds.height / snap.bounds.height
            )

            [fromView, snap].forEach { $0.center = transformView.bounds.midXY }
        }

        containerView.layer.sublayerTransform = TransformView.parentSublayerTransform

        let angle = CGFloat(Double.pi)
        toView?.alpha = 0.0001

        UIView.animateKeyframes(transitionDuration(using: context), animations: {
            UIView.addKeyframe(0, duration: 0.04) { fromView?.alpha = 1 }
            UIView.addKeyframe(0.04, duration: 0.05) { fromView?.alpha = 0 }
            UIView.addKeyframe(0.09, duration: 0.91) { fromView?.alpha = 0 }
        })

        UIView.springAnimate(
            transitionDuration(using: context),
            damping: 0.9,
            velocity: 0.6,
            animations: {
                transformView.layer.transform = CATransform3DTranslate(
                    CATransform3DMakeRotation(angle, 0, 1, 0),
                    translation.x,
                    translation.y,
                    0
                )
                snap?.transform = CGAffineTransform(
                    scaleX: -1 + self.scaleAdjustment,
                    y: 1 - self.scaleAdjustment
                )
                fromView?.layer.cornerRadius = (toView?.layer.cornerRadius
                    ?? Theme.padding) * 4
                fromView?.transform = CGAffineTransform(
                    scaleX: snapScale.width,
                    y: snapScale.height
                )
            },
            completion: { [weak self] success in
                snap?.removeFromSuperview()
                transformView.removeFromSuperview()
                toView?.alpha = 1
                if let fromView = fromView, context.transitionWasCancelled {
                    fromView.alpha = 1
                    containerView.addSubview(fromView)
                }
                context.completeTransition(!context.transitionWasCancelled)
                self?.handler?()
            }
        )
    }
}

class CardFlipInteractiveTransitioning: UIPercentDrivenInteractiveTransition {

    private var handler: (()->Void)? = nil

    init(handler: (()->Void)? = nil) {
        super.init()
        self.handler = handler
        wantsInteractiveStart = false
    }

    override func cancel() {
        super.cancel()
        handler?()
    }

    override func finish() {
        super.finish()
        handler?()
    }
}
