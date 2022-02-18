// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AMMsViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: AMMsViewModel.Error)
}

// MARK - Item

extension AMMsViewModel {

    struct Item {
        let title: String
    }
}

// MARK: - Error

extension AMMsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension AMMsViewModel {

    func items() -> [AMMsViewModel.Item] {
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