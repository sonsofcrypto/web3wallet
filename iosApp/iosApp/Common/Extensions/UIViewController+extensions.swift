// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIViewController {
    
    func addCloseButtonToNavigationBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close-icon"),
            style: .plain,
            target: self,
            action: #selector(dismissAction)
        )
        navigationItem.rightBarButtonItem?.tintColor  = Theme.color.tint
    }
    
    @objc func dismissAction() {

        fatalError("Please override by subclass")
    }
}
