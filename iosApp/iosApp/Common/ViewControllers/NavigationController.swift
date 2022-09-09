// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NavigationController: UINavigationController {
    
    private (set) var systemShadowColor: UIColor?
    
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
        systemShadowColor = appearance.shadowColor

        interactivePopGestureRecognizer?.delegate = self
    }
}

extension UINavigationController {
    
    var bottomLineColor: UIColor? {
        guard let navigationController = self as? NavigationController else {
            return nil
        }
        return navigationController.systemShadowColor
    }
    
    func showBottomLine(_ showBottomLine: Bool) {
        let appearance = navigationBar.standardAppearance
        appearance.shadowColor = showBottomLine
            ? bottomLineColor
            : .clear
        navigationBar.scrollEdgeAppearance = appearance
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
