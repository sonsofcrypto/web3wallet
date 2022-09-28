// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AppsViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: AppsViewModel.Error)
}

extension AppsViewModel {
    struct Item {
        let title: String
    }
}

extension AppsViewModel {
    // TODO: Use AlertViewModel here and remove this struct (not needed)
    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

extension AppsViewModel {
    func items() -> [AppsViewModel.Item] {
        switch self {
        case let .loaded(items, _): return items
        default: return []
        }
    }

    func selectedIdx() -> Int? {
        switch self {
        case let .loaded(_, idx): return idx
        default: return nil
        }
    }
}
