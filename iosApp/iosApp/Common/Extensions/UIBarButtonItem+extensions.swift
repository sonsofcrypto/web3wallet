// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIBarButtonItem {

    static func glowLabel(_ title: String = "") -> UIBarButtonItem {
        let label = UILabel(with: .subheadGlow)
        label.font = UIFont.font(.gothicA1, style: .regular, size: .caption1)
        return UIBarButtonItem(customView: label)
    }
}

