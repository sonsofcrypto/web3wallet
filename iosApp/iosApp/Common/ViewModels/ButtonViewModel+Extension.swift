// Created by web3dev on 02/01/2024.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import Foundation
import web3walletcore

extension ButtonViewModel {
    
    convenience init(title: String, kind: ButtonViewModel.Kind) {
        self.init(title: title, kind: kind, iconName: nil)
    }

}
