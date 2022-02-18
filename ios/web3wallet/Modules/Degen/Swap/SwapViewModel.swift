// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SwapViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: SwapViewModel.Error)
}

// MARK - Item

extension SwapViewModel {

    struct Item {
        let title: String
    }
}

// MARK: - Error

extension SwapViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension SwapViewModel {

    func items() -> [SwapViewModel.Item] {
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