// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIBarButtonItem {
    
    convenience init(
        imageName: String,
        style: UIBarButtonItem.Style = .plain,
        target: Any?,
        selector: Selector?
    ) {
        self.init(
            image: UIImage(named: imageName),
            style: .plain,
            target: target,
            action: selector
        )
    }

    static func glowLabel(_ title: String = "") -> UIBarButtonItem {
        
        let label = UILabel(with: .subheadline)
        label.font = UIFont.font(.gothicA1, style: .regular, size: .caption1)
        return UIBarButtonItem(customView: label)
    }
}

