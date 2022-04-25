// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = tabBar.standardAppearance
        appearance.backgroundColor = Theme.color.background.withAlphaComponent(1)

        let itemAppearance = appearance.inlineLayoutAppearance

        itemAppearance.normal.iconColor = Theme.color.textTertiary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: Theme.color.textTertiary,
            .font: Theme.font.tabBar,
        ]

        itemAppearance.selected.iconColor = Theme.color.tintSecondary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: Theme.color.tintSecondary,
            .font: Theme.font.tabBar,
        ]

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.tintColor = Theme.color.tintSecondary
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
