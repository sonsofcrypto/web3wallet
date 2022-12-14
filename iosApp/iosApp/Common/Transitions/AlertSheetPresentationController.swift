// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AlertSheetPresentationController: UIPresentationController {
    
    private var contentHeight: CGFloat!
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        contentHeight: CGFloat
    ) {
        
        self.contentHeight = contentHeight
        
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }
    
    private weak var bgView: UIView?

    override var frameOfPresentedViewInContainerView: CGRect {
        
        let size: CGSize = .init(
            width: containerViewBounds().width - (Theme.padding * 2),
            height: contentHeight
        )
        let bounds = containerViewBounds()
        return .init(
            origin: .init(
                x: (bounds.width - size.width) / 2,
                y: (bounds.height - size.height) / 2
            ),
            size: size
        )
    }

    override func presentationTransitionWillBegin() {
        
        super.presentationTransitionWillBegin()
        
        // Animate background
        let bgView = newBGView()
        containerView?.addSubview(bgView)
        self.bgView = bgView
        presentedView?.layer.cornerRadius = Theme.cornerRadius

        UIView.animate(withDuration: Constant.animDuration) {
            self.bgView?.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        
        super.dismissalTransitionWillBegin()

        UIView.animate(withDuration: Constant.animDuration) {
            self.bgView?.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        super.dismissalTransitionDidEnd(completed)

        guard !completed else {
            bgView?.removeFromSuperview()
            return
        }

        UIView.animate(withDuration: Constant.animDuration) {
            self.bgView?.alpha = 1.0
        }
    }

    override func containerViewWillLayoutSubviews() {
        
        super.containerViewWillLayoutSubviews()
        
        bgView?.frame = containerView?.bounds ?? .zero
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }

    override func adaptivePresentationStyle(
        for traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        
        .custom
    }
}

private extension AlertSheetPresentationController {
    
    func motionEffect(
        _ keyPath: String,
        type: UIInterpolatingMotionEffect.EffectType
    ) -> UIInterpolatingMotionEffect {
        
        UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
    }

    func newBGView() -> UIView {
        
        let bgView = UIView(frame: containerViewBounds())
        if Theme.isThemeIOSDarkSelected {
            bgView.backgroundColor = UIColor.white.withAlpha(0.15)
        } else {
            bgView.backgroundColor = UIColor.black.withAlpha(0.55)
        }
        bgView.alpha = 0
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapAction(_:))
        )
        bgView.addGestureRecognizer(tap)
        return bgView
    }
    
    @objc func tapAction(_ recognizer: UITapGestureRecognizer) {
        
        if let vc = presentingViewController as? ModalDismissProtocol {
            vc.modalDismissDelegate?.viewControllerDismissActionPressed(presentedViewController)
        } else if let vc = presentedViewController as? ModalDismissDelegate {
            vc.viewControllerDismissActionPressed(presentedViewController)
        } else if let vc = presentedViewController as? UINavigationController,
                  let childVc = vc.topViewController as? ModalDismissDelegate {
            childVc.viewControllerDismissActionPressed(presentedViewController)
        } else {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    func containerViewBounds() -> CGRect {
        
        containerView?.bounds ?? presentingViewController.view.bounds
    }

    private struct Constant {
        
        static let animDuration: TimeInterval = 0.2
    }
}
