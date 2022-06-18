// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension UITabBarController {
    
    func add(
        viewController: UIViewController
    ) -> [UIViewController] {
        
        (viewControllers ?? []) + [viewController]
    }
}
