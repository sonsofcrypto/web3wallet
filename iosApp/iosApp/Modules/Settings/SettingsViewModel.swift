// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct SettingsViewModel {
    let sections: [Section]
    
    struct Section {
        let items: [CellViewModel]
    }
}
