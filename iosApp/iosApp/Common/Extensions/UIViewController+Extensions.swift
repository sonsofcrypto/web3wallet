// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIViewController {
    
    func configureNavigationBar(title: String?) {
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.applyStyle(.navTitle)
        navigationItem.titleView = titleLabel
    }

//    let titleLabel = UILabel(frame: .zero)
//    titleLabel.textAlignment = .center
//    titleLabel.text = viewModel?.title
//    titleLabel.applyStyle(.navTitle)
//
//    let views: [UIView] = [
//        titleLabel
//    ]
//    let vStack = VStackView(views)
//    vStack.spacing = 4
//    navigationItem.titleView = vStack

    
    func configureLeftBarButtonItemDismissAction() {
        
        let icon = navigationController?.viewControllers.count == 1 ? "close_icon" : "arrow_back"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: icon),
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor  = Theme.color.tint
    }
    
    @objc func dismissTapped() {

        fatalError("Please override by subclass")
    }
}
