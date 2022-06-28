// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
                        
        let appearance = tabBar.standardAppearance
        let itemAppearance = appearance.inlineLayoutAppearance

        switch Theme.type {
        case .themeOG:
            appearance.backgroundColor = Theme.colour.backgroundBaseSecondary.withAlphaComponent(1)

            itemAppearance.normal.iconColor = Theme.colour.labelTertiary
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: Theme.colour.labelTertiary,
                .font: Theme.font.tabBar,
            ]

            itemAppearance.selected.iconColor = Theme.colour.fillSecondary
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: Theme.colour.fillSecondary,
                .font: Theme.font.tabBar,
            ]
            
            tabBar.tintColor = Theme.colour.fillSecondary

        case .themeA:
            appearance.backgroundColor = UIColor(rgb: 0x555453)
        
            itemAppearance.normal.iconColor = Theme.colour.systemBlue
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: Theme.colour.systemBlue,
                .font: Theme.font.tabBar,
            ]

            itemAppearance.selected.iconColor = Theme.colour.systemPink
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: Theme.colour.systemPink,
                .font: Theme.font.tabBar,
            ]
            
            tabBar.tintColor = Theme.colour.systemPink
        }

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
