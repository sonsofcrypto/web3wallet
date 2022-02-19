// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = navigationBar.standardAppearance
        let titleShadow = NSShadow()
        titleShadow.shadowOffset = .zero
        titleShadow.shadowBlurRadius = Global.shadowRadius
        titleShadow.shadowColor = Theme.current.tintPrimary

        appearance.titleTextAttributes = [
            .foregroundColor: Theme.current.tintPrimary,
            .font: Theme.current.navTitle,
            .shadow: titleShadow
        ]

        appearance.backgroundColor = Theme.current.background.withAlphaComponent(1)

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
    }
}
