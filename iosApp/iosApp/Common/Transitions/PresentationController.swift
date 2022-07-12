// Created by web3d3v on 12/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class PresentationController: UIPresentationController {

    /// Tap recognizer on area outside of the view
    private(set) weak var chromeTapGestureRecognizer: UITapGestureRecognizer?
    /// Shadow chrome for drawer
    private weak var backgroundView: UIView? // GradientView?
    /// Container view is optional, for convenience always get valid frame
    private var containerBounds: CGRect {
        containerView?.bounds ?? presentingViewController.view.bounds
    }

    private var presentedPreferredContentSize: CGSize {
        let size = presentedViewController.preferredContentSize
        return .init(
            width: max(0.8 * containerBounds.width, size.width),
            height: max(0.3 * containerBounds.height, size.height)
        )
    }

    // MARK: - Transitioning

    override var frameOfPresentedViewInContainerView: CGRect {
        .init(
            origin: .init(
                x: (containerBounds.width - preferredContentSize.width) / 2,
                y: (containerBounds.height - preferredContentSize.height) / 2
            ),
            size: preferredContentSize
        )
    }

    private var frameOfPresentedGradientViewInContainerView: CGRect {
        containerBounds
    }

    override func presentationTransitionWillBegin() {
        setupChromeView()
        presentingViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] _ in
                self?.backgroundView?.alpha = 1
            },
            completion: { [weak self] coordinator in
                if coordinator.isCancelled {
                    self?.backgroundView?.removeFromSuperview()
                }
            }
        )
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            backgroundView?.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] _ in
                self?.backgroundView?.alpha = 0
            },
            completion: nil
        )
    }

    private func setupChromeView () {
        let chromeView = UIView(frame: containerBounds)
        chromeView.alpha = 0
        chromeView.backgroundColor = .black.withAlpha(0.2)
        chromeView.translatesAutoresizingMaskIntoConstraints = false
        containerView?.addSubview(chromeView)
        self.backgroundView = chromeView

        let recognizer = UITapGestureRecognizer()
        chromeView.addGestureRecognizer(recognizer)
        self.chromeTapGestureRecognizer = recognizer
    }
}