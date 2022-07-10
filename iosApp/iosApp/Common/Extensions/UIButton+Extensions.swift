// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIButton {

    func removeAllTargets() {
        allTargets.forEach {
            self.removeTarget($0, action: nil, for: .touchUpInside)
        }
    }
}

extension UIButton {
    
    enum Web3WalletButtonStyle {
        
        case primary
        case dashboardAction
    }
    
    func apply(style: Web3WalletButtonStyle) {
        
        switch style {
        case .primary:
            applyPrimaryStyle()
        case .dashboardAction:
            applyDashboardActionStyle()
        }
    }
}

private extension UIButton {
    
    func applyPrimaryStyle() {
        
        addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: Theme.constant.buttonPrimaryHeight)
                )
            ]
        )
        
        backgroundColor = Theme.colour.buttonBackgroundPrimary
        tintColor = Theme.colour.labelPrimary
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        titleLabel?.font = Theme.font.title3
        setTitleColor(Theme.colour.labelPrimary, for: .normal)
    }
    
    func applyDashboardActionStyle() {
        
        addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: Theme.constant.buttonDashboardActionHeight)
                )
            ]
        )
        
        backgroundColor = .clear
        tintColor = Theme.colour.labelPrimary
        layer.borderWidth = 0.5
        layer.borderColor = Theme.colour.labelPrimary.cgColor
        layer.cornerRadius = Theme.constant.cornerRadius
        titleLabel?.font = Theme.font.calloutBold
        setTitleColor(Theme.colour.labelPrimary, for: .normal)
        titleLabel?.textAlignment = .natural
        
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = Theme.constant.padding * 0.5
        self.configuration = configuration
        updateConfiguration()
    }
}
