// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
                        
        let appearance = tabBar.standardAppearance
        let itemAppearance = appearance.inlineLayoutAppearance

        let themeProvider: ThemeProvider = ServiceDirectory.assembler.resolve()

        switch themeProvider.current {
        case .themeOG:
            appearance.backgroundColor = ThemeOG.color.background.withAlphaComponent(1)

            itemAppearance.normal.iconColor = ThemeOG.color.textTertiary
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: ThemeOG.color.textTertiary,
                .font: ThemeOG.font.tabBar,
            ]

            itemAppearance.selected.iconColor = ThemeOG.color.tintSecondary
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: ThemeOG.color.tintSecondary,
                .font: ThemeOG.font.tabBar,
            ]
            
            tabBar.tintColor = ThemeOG.color.tintSecondary

        case let .themeHome(themeHome):
            appearance.backgroundColor = themeHome.tabBarColour().backgroundColour
            
            itemAppearance.normal.iconColor = themeHome.tabBarColour().itemNormalColour
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: themeHome.tabBarColour().itemNormalColour,
                .font: ThemeOG.font.tabBar,
            ]

            itemAppearance.selected.iconColor = themeHome.tabBarColour().itemSelectedColour
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: themeHome.tabBarColour().itemSelectedColour,
                .font: ThemeOG.font.tabBar,
            ]
            
            tabBar.tintColor = themeHome.tabBarColour().tintColour
        }

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
