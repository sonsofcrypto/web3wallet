// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalsViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: AppsViewModel.Error)
}

// MARK - Item

extension CultProposalsViewModel {

    struct Item {
        let title: String
        let approved: Float
        let rejected: Float
        let date: Date
    }
}

// MARK: - Error

extension CultProposalsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension CultProposalsViewModel {

    func items() -> [CultProposalsViewModel.Item] {
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