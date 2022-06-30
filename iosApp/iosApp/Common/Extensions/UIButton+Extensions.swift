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
        
        var height: CGFloat {
            
            switch self {
            case .primary:
                return 34
            }
        }
    }
    
    func apply(style: Web3WalletButtonStyle) {
        
        switch Theme.type {
        case .themeA:
            applyThemeHome(style: style)
        case .themeOG:
            applyThemeOG(style: style)
        }
    }
}

private extension UIButton {
    
    func applyThemeHome(style: Web3WalletButtonStyle) {
        
        switch style {
        case .primary:
            applyThemeHomePrimaryStyle()
        }
    }
    
    func applyThemeHomePrimaryStyle() {
        
        let style = Web3WalletButtonStyle.primary
        
        addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: style.height))
            ]
        )
        
        backgroundColor = .clear
        tintColor = Theme.colour.labelPrimary
        layer.borderWidth = 0.5
        layer.borderColor = Theme.colour.labelPrimary.cgColor
        layer.cornerRadius = style.height * 0.5
        titleLabel?.font = Theme.font.callout
        setTitleColor(Theme.colour.labelPrimary, for: .normal)
        titleLabel?.textAlignment = .natural
        imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 4, right: 0)
    }
}

private extension UIButton {
    
    func applyThemeOG(style: Web3WalletButtonStyle) {
        
        switch style {
        case .primary:
            applyThemeOGPrimaryStyle()
        }
    }
    
    func applyThemeOGPrimaryStyle() {
        
        let height: CGFloat = 33
        
        addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: height))
            ]
        )
        
        tintColor = Theme.colour.labelPrimary
        layer.cornerRadius = Theme.constant.cornerRadius
        titleLabel?.font = Theme.font.caption1
        titleLabel?.textAlignment = .center
    }
}
