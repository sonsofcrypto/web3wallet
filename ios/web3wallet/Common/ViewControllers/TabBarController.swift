//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = tabBar.standardAppearance
        appearance.backgroundColor = Theme.current.background.withAlphaComponent(1)

        let itemAppearance = appearance.inlineLayoutAppearance

        itemAppearance.normal.iconColor = Theme.current.textColorTertiary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: Theme.current.textColorTertiary,
            .font: Theme.current.tabBar,
        ]

        itemAppearance.selected.iconColor = Theme.current.tintSecondary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: Theme.current.tintSecondary,
            .font: Theme.current.tabBar,
        ]

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.tintColor = Theme.current.tintSecondary
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
