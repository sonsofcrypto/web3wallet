// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum KeyStoreViewModel {
    case loading
    case loaded(wallets: [Wallet], selectedIdx: Int)
    case error(error: KeyStoreViewModel.Error)
}

// MARK - Wallet

extension KeyStoreViewModel {

    struct Wallet {
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

    func wallets() -> [KeyStoreViewModel.Wallet] {
        switch self {
        case let .loaded(wallets, _):
            return wallets
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