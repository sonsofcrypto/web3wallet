// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NavigationController: UINavigationController {

    weak var contentView: UIView? {
        didSet { didSetContentView(contentView, prevView: oldValue) }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        Theme.statusBarStyle.statusBarStyle(for: traitCollection.userInterfaceStyle)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = navigationBar.standardAppearance
        appearance.backgroundColor = Theme.colour.navBarBackground
        appearance.titleTextAttributes = [
            .foregroundColor: Theme.colour.navBarTitle,
            .font: Theme.font.navTitle
        ]
        appearance.setBackIndicatorImage(
            "chevron.left".assetImage,
            transitionMaskImage:  nil
        )
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.tintColor = Theme.colour.navBarTint
        interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutBar()
    }
}

extension UINavigationController {

    var topVc: UIViewController? {
        topViewController
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        viewControllers.count > 1
    }
}

private extension NavigationController {

    func didSetContentView(_ contentView: UIView?, prevView: UIView?) {
        guard contentView != prevView else { return }
        prevView?.removeFromSuperview()
        view.setNeedsLayout()
        if let contentView = contentView {
            contentView.alpha = 0
            view.addSubview(contentView)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                contentView.alpha = 1
            }
        }
    }

    func layoutBar() {
        guard let contentView = contentView else {
            topVc?.additionalSafeAreaInsets = UIEdgeInsets.zero
            return
        }

        var barFrame = navigationBar.frame
        barFrame.size.height += contentView.intrinsicContentSize.height
        barFrame.size.height += Theme.constant.padding
        navigationBar.frame = barFrame

        var contentFrame = barFrame.insetBy(dx: Theme.constant.padding, dy: 0)
        contentFrame.size.height = contentView.bounds.height
        contentFrame.origin.y = barFrame.maxY - Theme.constant.padding
        contentFrame.origin.y -= contentView.bounds.height
        contentView.frame = contentFrame

        topVc?.additionalSafeAreaInsets = UIEdgeInsets.with(
            top: barFrame.maxY - contentFrame.minY
        )
    }
}
