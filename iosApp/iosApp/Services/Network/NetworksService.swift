// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NetworksService {

    func networkIcon(for network: Web3Network) -> Data
    func allNetworks() -> [Web3Network]
    func update(network: Web3Network, active: Bool)
}
