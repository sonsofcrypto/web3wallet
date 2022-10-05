// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NavigationController: UINavigationController {

//    convenience init(rootVc: UIViewContro)

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
