// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIButton {
    
    func showLoading() {
        var configuration = configuration
        configuration?.showsActivityIndicator = true
        self.configuration = configuration
        updateConfiguration()
    }
    
    func hideLoading() {
        var configuration = configuration
        configuration?.showsActivityIndicator = false
        self.configuration = configuration
        updateConfiguration()
    }

    func removeAllTargets() {
        allTargets.forEach {
            self.removeTarget($0, action: nil, for: .touchUpInside)
        }
    }
}
