// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = Theme.current.tintPrimary
        navigationBar.barTintColor = Theme.current.background
        navigationBar.titleTextAttributes = [
            .foregroundColor: Theme.current.tintPrimary,
            .font: Theme.current.navTitle,
        ]
    }
}
