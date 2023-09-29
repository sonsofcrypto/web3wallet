// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIViewController {
    var asEdgeCardsController: EdgeCardsController? {
        self as? EdgeCardsController
    }
    
    var asNavVc: NavigationController? {
        self as? NavigationController
    }
    
    func popOrDismiss() {
        if let nc = navigationController?.asNavVc, nc.viewControllers.count > 1 {
            _ = nc.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
