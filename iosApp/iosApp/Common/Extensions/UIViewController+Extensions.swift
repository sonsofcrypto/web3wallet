// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIViewController {
    var asEdgeCardsController: EdgeCardsController? {
        self as? EdgeCardsController
    }
    
    var asNavigationController: NavigationController? {
        self as? NavigationController
    }
    
    func popOrDismiss() {
        if let nc = asNavigationController, nc.canPop {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension NavigationController {
    var canPop: Bool { viewControllers.count > 1 }
}
