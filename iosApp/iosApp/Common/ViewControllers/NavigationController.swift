// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = navigationBar.standardAppearance

        switch Theme.type {
            
        case .themeOG:
            
            let titleShadow = NSShadow()
            titleShadow.shadowOffset = .zero
            titleShadow.shadowBlurRadius = Global.shadowRadius
            appearance.backgroundColor = Theme.colour.backgroundBaseSecondary.withAlphaComponent(1)
            appearance.titleTextAttributes = [
                .foregroundColor: Theme.colour.fillPrimary,
                .font: Theme.font.navTitle,
                .shadow: titleShadow
            ]
            titleShadow.shadowColor = Theme.colour.fillPrimary

        case .themeA:
            
            appearance.backgroundColor = Theme.colour.navBarBackground
            appearance.titleTextAttributes = [
                .foregroundColor: Theme.colour.navBarTint,
                .font: Theme.font.navTitle
            ]
        }
        
        appearance.setBackIndicatorImage(
            UIImage(named: "nav_bar_back"),
            transitionMaskImage:  nil
        )

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        
        interactivePopGestureRecognizer?.delegate = nil
    }
}
