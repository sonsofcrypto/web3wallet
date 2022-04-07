//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol NetworksService {

    typealias NetworksHandler = ([Network]) -> ()

    var active: Network? { get set }

    func availableNetworks() -> [Network]
    func updateStatus(_ networks: [Network], handler: @escaping NetworksHandler)
}

class DefaultNetworksService {

    var active: Network? = Network(
        id: 60,
        name: "Ethereum",
        url: nil,
        connectionType: .liteClient,
        status: .unknown,
        explorer: .liteClientOnly
    )
}

// MARK: - NetworksService

extension DefaultNetworksService: NetworksService {

    func availableNetworks() -> [Network] {
        return [
            Network(
                id: 60,
                name: "Ethereum",
                url: nil,
                connectionType: .liteClient,
                status: .unknown,
                explorer: .liteClientOnly
            ),
            Network(
                id: 90,
                name: "Solana",
                url: nil,
                connectionType: .networkDefault,
                status: .unknown,
                explorer: .web2
            ),
        ]
    }

    func updateStatus(_ networks: [Network], handler: @escaping NetworksHandler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler(
                [
                    Network(
                        id: 60,
                        name: "Ethereum",
                        url: nil,
                        connectionType: .liteClient,
                        status: .connected,
                        explorer: .liteClientOnly
                    ),
                    Network(
                        id: 90,
                        name: "Solana",
                        url: nil,
                        connectionType: .networkDefault,
                        status: .disconnected,
                        explorer: .web2
                    ),
                ]
            )
        }
    }
}
