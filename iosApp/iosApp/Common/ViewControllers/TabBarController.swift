// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
                        
        let appearance = tabBar.standardAppearance
        let itemAppearance = appearance.inlineLayoutAppearance

        appearance.backgroundColor = Theme.colour.backgroundElevatedPrimary
        
        itemAppearance.normal.iconColor = Theme.colour.tabBarTint
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: Theme.colour.tabBarTint,
            .font: Theme.font.tabBar,
        ]
        
        itemAppearance.selected.iconColor = Theme.colour.tabBarTintSelected
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: Theme.colour.tabBarTintSelected,
            .font: Theme.font.tabBar,
        ]
        tabBar.tintColor = Theme.colour.tabBarTint

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
