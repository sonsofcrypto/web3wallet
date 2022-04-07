//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

enum SettingsViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: SettingsViewModel.Error)
}

// MARK - Item

extension SettingsViewModel {

    struct Item {
        let title: String
    }
}

// MARK: - Error

extension SettingsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension SettingsViewModel {

    func items() -> [SettingsViewModel.Item] {
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
