// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct NetworksViewModel {
    let header: String
    let sections: [Section]
}

extension NetworksViewModel {

    struct Section {
        let header: String
        let networks: [Network]
    }
}

extension NetworksViewModel {

    struct Network {
        let chainId: UInt32
        let name: String
        let connected: Bool
        let imageData: Data
        let connectionType: String
    }
}
