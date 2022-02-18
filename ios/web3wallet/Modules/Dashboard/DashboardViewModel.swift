// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum DashboardViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: DashboardViewModel.Error)
}

// MARK - Item

extension DashboardViewModel {

    struct Item {
        let title: String
    }
}

// MARK: - Error

extension DashboardViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension DashboardViewModel {

    func items() -> [DashboardViewModel.Item] {
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