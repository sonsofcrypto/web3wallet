//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol NetworksInteractor: AnyObject {

    typealias NetworksHandler = ([Network]) -> ()

    var active: Network? { get set }

    func availableNetworks() -> [Network]
    func updateStatus(_ networks: [Network], handler: @escaping NetworksHandler)
}

// MARK: - DefaultNetworksInteractor

class DefaultNetworksInteractor {

    private var networksService: NetworksService

    var active: Network? {
        get { networksService.active }
        set { networksService.active = newValue }
    }
    init(_ networksService: NetworksService) {
        self.networksService = networksService
    }
}

// MARK: - DefaultNetworksInteractor

extension DefaultNetworksInteractor: NetworksInteractor {

    func availableNetworks() -> [Network] {
        networksService.availableNetworks()
    }

    func updateStatus(_ networks: [Network], handler: @escaping NetworksHandler) {
        networksService.updateStatus(networks, handler: handler)
    }
}
