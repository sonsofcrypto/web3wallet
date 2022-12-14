// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NavigationItem: UINavigationItem {
    @IBOutlet var contentView: UIView?
}

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
        appearance.backgroundColor = Theme.color.navBarBackground
        appearance.titleTextAttributes = [
            .foregroundColor: Theme.color.navBarTitle,
            .font: Theme.font.navTitle
        ]
        appearance.setBackIndicatorImage(
            "chevron.left".assetImage,
            transitionMaskImage: "chevron.left".assetImage
        )

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.tintColor = Theme.color.navBarTint
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

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        contentView = contentView(for: viewController)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        contentView = contentView(for: viewControllers.last)
        return vc
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let idx = viewControllers.firstIndex(of: viewController), idx > 0 {
            contentView = contentView(for: viewControllers[idx - 1])
        }
        let vcs = super.popToViewController(viewController, animated: animated)
        return vcs
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        contentView = contentView(for: viewControllers[safe: 0])
        let vcs = super.popToRootViewController(animated: animated)
        return vcs
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
            navigationBar.setNeedsLayout()
            view.addSubview(contentView)
            contentView.alpha = 0
            UIView.animate(withDuration: 0.15) {
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

    func contentView(for viewController: UIViewController?) -> UIView? {
        (viewController?.navigationItem as? NavigationItem)?.contentView
    }
}
