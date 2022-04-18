// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = tabBar.standardAppearance
        appearance.backgroundColor = ThemeOld.current.background.withAlphaComponent(1)

        let itemAppearance = appearance.inlineLayoutAppearance

        itemAppearance.normal.iconColor = ThemeOld.current.textColorTertiary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: ThemeOld.current.textColorTertiary,
            .font: ThemeOld.current.tabBar,
        ]

        itemAppearance.selected.iconColor = ThemeOld.current.tintSecondary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: ThemeOld.current.tintSecondary,
            .font: ThemeOld.current.tabBar,
        ]

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.tintColor = ThemeOld.current.tintSecondary
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
