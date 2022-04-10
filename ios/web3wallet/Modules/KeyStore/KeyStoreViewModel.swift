// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum KeyStoreViewModel {
    case loading(isEmpty: Bool)
    case loaded(wallets: [KeyStoreItem], selectedIdx: Int, isEmpty: Bool)
    case error(error: KeyStoreViewModel.Error, isEmpty: Bool)
}

// MARK - Wallet

extension KeyStoreViewModel {

    struct KeyStoreItem {
        let title: String
    }
}

// MARK: - Error

extension KeyStoreViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - Utility

extension KeyStoreViewModel {

    func wallets() -> [KeyStoreViewModel.KeyStoreItem] {
        switch self {
        case let .loaded(wallets, _, _):
            return wallets
        default:
            return []
        }
    }

    func selectedIdx() -> Int? {
        switch self {
        case let .loaded(_, idx, _):
            return idx
        default:
            return nil
        }
    }

    func isEmpty() -> Bool {
        switch self {
        case let .loading(isEmpty):
            return isEmpty
        case let .loaded(_, _, isEmpty):
            return isEmpty
        case let .error(_, isEmpty):
            return isEmpty
        }
    }
}