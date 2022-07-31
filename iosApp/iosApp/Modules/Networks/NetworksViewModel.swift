// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct NetworksViewModel {
    let header: String
    let sections: [Section]

    func count() -> Int {
        sections.reduce(0, { $0 + $1.networks.count })
    }

    func selectedIndexPaths() -> [IndexPath] {
        var idxPaths = [IndexPath]()
        for (sIdx, section) in sections.enumerated() {
            for (nIdx, network) in section.networks.enumerated() {
                if network.isSelected {
                    idxPaths.append(IndexPath(item: nIdx, section: sIdx))
                }
            }
        }
        return idxPaths
    }
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
        let isSelected: Bool
    }
}
