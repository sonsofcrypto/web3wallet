// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum TemplateViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: AppsViewModel.Error)
}

// MARK - Item

extension AppsViewModel {

    struct Item {
        let title: String
    }
}

// MARK: - Error

extension AppsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension AppsViewModel {

    func items() -> [AppsViewModel.Item] {
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