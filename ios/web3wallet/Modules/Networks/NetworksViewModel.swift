//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

enum NetworksViewModel {
    case loaded(networks: [Network], selectedIdx: Int)
    case error(error: NetworksViewModel.Error)
}

// MARK - Item

extension NetworksViewModel {

    struct Network {
        let name: String
        let connectionType: String
        let status: String
        let explorer: String
        let connected: Bool
    }
}

// MARK: - Error

extension NetworksViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension NetworksViewModel {

    func network() -> [NetworksViewModel.Network] {
        switch self {
        case let .loaded(items, _):
            return items
        default:
            return []
        }
    }

    func selectedIdx() -> Int? {
        switch self {
        case let .loaded(_, idx):
            return idx
        default:
            return nil
        }
    }
}
