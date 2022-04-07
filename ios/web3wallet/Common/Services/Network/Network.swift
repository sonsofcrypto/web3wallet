//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

struct Network {
    let id: Int
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
        case networkDefault
        case infura
        case alchyme
    }
}

// MARK: - Status

extension Network {

    enum Status {
        case unknown
        case connected
        case connectedSync(pct: Float)
        case disconnected
    }
}

// MARK: - Explorer

extension Network {

    enum Explorer {
        case liteClientOnly
        case web2
    }
}
