// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DismissFromModal: NSObject, UIViewControllerAnimatedTransitioning {

    var targetView: UIView
    var isPresenting: Bool

    init(targetView: UIView, isPresenting: Bool = true) {
        self.targetView = targetView
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 0.9 : 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVc = transitionContext.viewController(forKey: .from)
        let toVc = transitionContext.viewController(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView

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

        print("=== from", fromView)

        let fromSnap = fromView?.snapshotView(afterScreenUpdates: false)
        let toSnap = toView?.snapshotView(afterScreenUpdates: true)
        let snapContainer = UIView(frame: .zero)
        snapContainer.clipsToBounds = true
        snapContainer.contentMode = .top
        snapContainer.layer.cornerRadius = Global.cornerRadius
        fromSnap?.contentMode = .top
        toSnap?.contentMode = .top

        if let fromSnap = fromSnap, let toSnap = toSnap, let fromView = fromView {
            containerView.addSubview(fromSnap)
            containerView.addSubview(snapContainer)

            fromSnap.frame = fromView.convert(fromView.bounds, to: containerView)
            snapContainer.frame = fromSnap.frame
            toSnap.frame = snapContainer.bounds
            snapContainer.addSubview(toSnap)
        }

        fromView?.alpha = 0

        UIView.springAnimate(
            transitionDuration(using: context) / 4,
            animations: { snapContainer.alpha = 1 }
        )

        UIView.springAnimate(
            transitionDuration(using: context),
            damping: 0.9,
            velocity: 0.5,
            animations: {
                fromSnap?.frame = containerView.bounds
                snapContainer.frame = containerView.bounds
                toSnap?.frame = snapContainer.bounds
                snapContainer.layer.cornerRadius = 0
            },
            completion: { success in
                fromSnap?.removeFromSuperview()
                toSnap?.removeFromSuperview()
                snapContainer.removeFromSuperview()
                fromView?.alpha = 1

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

        UIView.springAnimate(
            transitionDuration(using: context),
            damping: 0.9,
            velocity: 0.5,
            animations: {
                transformView.layer.transform = CATransform3DTranslate(
                    CATransform3DMakeRotation(angle, 0, 1, 0),
                    translation.x,
                    translation.y,
                    0
                )
                snap?.transform = CGAffineTransform(scaleX: -1, y: 1)
                fromView?.transform = CGAffineTransform(
                    scaleX: snapScale.width,
                    y: snapScale.height
                )
            },
            completion: { success in
                snap?.removeFromSuperview()
                transformView.removeFromSuperview()
                toView?.alpha = 1
                context.completeTransition(success)
            }
        )
    }

    func animationEnded(transitionCompleted: Bool) {

    }
}
