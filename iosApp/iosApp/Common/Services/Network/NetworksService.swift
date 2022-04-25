// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NetworksService {

    typealias NetworksHandler = ([Network]) -> ()

    var active: Network? { get set }

    func availableNetworks() -> [Network]
    func updateStatus(_ networks: [Network], handler: @escaping NetworksHandler)
}
