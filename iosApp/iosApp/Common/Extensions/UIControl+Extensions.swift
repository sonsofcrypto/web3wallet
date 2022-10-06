// Created by web3d3v on 06/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIControl {

    func addValueChangedTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .valueChanged)
    }
}
