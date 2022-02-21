// Created by web3d3v on 21/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit


class CardFlipAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {

    var targetView: UIView
    var isPresenting: Bool

    init(targetView: UIView, isPresenting: Bool = true) {
        self.targetView = targetView
        self.isPresenting = isPresenting
        super.init()

    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 1.0 : 0.75
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVc = transitionContext.viewController(forKey: .from)
        let toVc = transitionContext.viewController(forKey: .to)
        let fromView = transitionContext.view(forKey: .to)
        let toView = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        containerView.layer.sublayerTransform = transform

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
        toView?.frame = containerView.bounds

        let toViewContainer = UIView(frame: containerView.bounds)
        toViewContainer.backgroundColor = .clear

        let snap = fromView?.snapshotView(afterScreenUpdates: false)
        var snapTransform = CATransform3DIdentity

        if let toView = toView, let fromView = fromView, let snap = snap {

            snap.center = containerView.convert(fromView.bounds.midXY, from: fromView)

            let rotation = CATransform3DMakeRotation(
                (CGFloat(Double.pi) - 0.001), 0, 1, 0
            )

            let scale = CATransform3DMakeScale(
                snap.bounds.width / toView.bounds.width,
                snap.bounds.height / toView.bounds.height,
                0
            )

            let translation = CATransform3DMakeTranslation(
                -(snap.center.x - toView.center.x),
                snap.center.y - toView.center.y,
                0
            )

            let snapRotation = CATransform3DMakeRotation(
                -(CGFloat(Double.pi) - 0.001), 0, 1, 0
            )

            let snapTranslation = CATransform3DMakeTranslation(
                toView.center.x - snap.center.x,
                toView.center.y - snap.center.y,
                0
            )

            snapTransform = CATransform3DConcat(snapRotation, snapTranslation)
            toViewContainer.layer.transform = rotation
            toView.layer.transform = CATransform3DConcat(scale, translation)

            toViewContainer.addSubview(toView)
            containerView.addSubview(toViewContainer)
            containerView.addSubview(snap)
        }

        UIView.springAnimate(
            transitionDuration(using: context),
            damping: 0.9,
            animations: {
                toViewContainer.layer.transform = CATransform3DIdentity
                toView?.layer.transform = CATransform3DIdentity
                snap?.layer.transform = snapTransform
                snap?.layer.zPosition = -1
            },
            completion: { success in
                snap?.removeFromSuperview()
                toViewContainer.removeFromSuperview()
                if let toView = toView {
                    containerView.addSubview(toView)
                }
                context.completeTransition(success)
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
//        if let toView = toView ?? toVc?.view, let fromView = fromView {
//            containerView.insertSubview(toView, belowSubview: fromView)
//        }

        UIView.springAnimate(
            transitionDuration(using: context),
            damping: 0.9,
            velocity: 0.2,
            animations: {
                fromView?.transform = CGAffineTransform(
                    translationX: 0,
                    y: UIScreen.main.bounds.size.height
                )
            },
            completion: { success in
                context.completeTransition(success)
            }
        )
    }

     func animationEnded(transitionCompleted: Bool) {

    }
}