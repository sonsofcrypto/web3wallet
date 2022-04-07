//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

enum NFTsViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: NFTsViewModel.Error)
}

// MARK - Item

extension NFTsViewModel {

    struct Item {
        let title: String
    }
}

// MARK: - Error

extension NFTsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension NFTsViewModel {

    func items() -> [NFTsViewModel.Item] {
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
