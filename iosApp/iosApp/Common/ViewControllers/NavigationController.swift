// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = navigationBar.standardAppearance

        let themeProvider: ThemeProvider = ServiceDirectory.assembler.resolve()
        
        switch themeProvider.current {
        case .themeOG:
            let titleShadow = NSShadow()
            titleShadow.shadowOffset = .zero
            titleShadow.shadowBlurRadius = Global.shadowRadius
            appearance.backgroundColor = ThemeOG.color.background.withAlphaComponent(1)
            appearance.titleTextAttributes = [
                .foregroundColor: ThemeOG.color.tint,
                .font: ThemeOG.font.navTitle,
                .shadow: titleShadow
            ]
            titleShadow.shadowColor = ThemeOG.color.tint

        case let .themeHome(themeHome):
            appearance.backgroundColor = themeHome.navBarColour().backgroundColour
            appearance.titleTextAttributes = [
                .foregroundColor: themeHome.navBarColour().foregroundColour,
                .font: themeHome.font(for: .navBarTitle)
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
