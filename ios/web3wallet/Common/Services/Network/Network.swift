// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct Network {
    let name: String
    let url: URL?
    let connectionType: ConnectionType
    let status: Status
    let explorer: Explorer
}

// MARK: - ConnectionType

extension Network {

    enum ConnectionType {
        case liteClient
        case infura
        case alchyme
    }
}

// MARK: - Status

extension Network {

    enum Status {
        case liteClient
        case infura
        case alchyme
    }
}

// MARK: - Explorer

extension Network {

    enum Explorer {
        case liteClientOnly
        case web3
    }
}
