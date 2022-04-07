//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = navigationBar.standardAppearance
        let titleShadow = NSShadow()
        titleShadow.shadowOffset = .zero
        titleShadow.shadowBlurRadius = Global.shadowRadius
        titleShadow.shadowColor = AppTheme.current.colors.tintPrimary

        appearance.titleTextAttributes = [
            .foregroundColor: AppTheme.current.colors.tintPrimary,
            .font: AppTheme.current.fonts.navTitle,
            .shadow: titleShadow
        ]

        appearance.backgroundColor = AppTheme.current.colors.background.withAlphaComponent(1)
        appearance.setBackIndicatorImage(
            UIImage(named: "arrow_back"),
            transitionMaskImage:  nil
        )

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
    }
}
