//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = tabBar.standardAppearance
        appearance.backgroundColor = AppTheme.current.colors.background.withAlphaComponent(1)

        let itemAppearance = appearance.inlineLayoutAppearance

        itemAppearance.normal.iconColor = AppTheme.current.colors.textColorTertiary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: AppTheme.current.colors.textColorTertiary,
            .font: AppTheme.current.fonts.tabBar,
        ]

        itemAppearance.selected.iconColor = AppTheme.current.colors.tintSecondary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppTheme.current.colors.tintSecondary,
            .font: AppTheme.current.fonts.tabBar,
        ]

        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.tintColor = AppTheme.current.colors.tintSecondary
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
