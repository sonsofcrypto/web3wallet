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
    
    func configureRightBarButtonItemAction(icon: String, tint: UIColor = Theme.color.tint) {
        
        let button = UIButton()
        button.setImage(
            .init(named: icon),
            for: .normal
        )
        button.tintColor = tint
        button.addTarget(self, action: #selector(navBarRightBarActionTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func navBarRightBarActionTapped() {

        fatalError("Please override by subclass")
    }
}
