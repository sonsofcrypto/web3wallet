// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIViewController {
    
    func configureNavigationBar(title: String?) {
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        switch Theme.type {
        case .themeOG:
            titleLabel.applyStyle(.navTitle)
            titleLabel.text = title
        case .themeA:
            titleLabel.text = title?.capitalized
        }
        navigationItem.titleView = titleLabel
    }

    func configureNavBarLeftAction(icon: String? = nil) {
        
        let icon = icon ?? (navigationController?.viewControllers.count == 1 ? "close_icon" : "arrow_back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: icon),
            style: .plain,
            target: self,
            action: #selector(navBarLeftActionTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = themeNavBarTint
    }
    
    @objc func navBarLeftActionTapped() {

        fatalError("Please override by subclass")
    }
    
    func configureNavBarRightAction(icon: String) {
        
        let button = UIButton()
        button.setImage(
            .init(named: icon),
            for: .normal
        )
        button.tintColor = themeNavBarTint
        button.addTarget(self, action: #selector(navBarRightActionTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func navBarRightActionTapped() {

        fatalError("Please override by subclass")
    }
}

extension UIViewController {}

private extension UIViewController {
    
    var themeNavBarTint: UIColor? {
        
        switch Theme.type {
        case .themeOG:
            return Theme.colour.fillPrimary
        case .themeA:
            return .init(named: "orange")
        }
    }
}
