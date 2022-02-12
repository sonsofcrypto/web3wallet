// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum WalletsViewModel {
    case loading
    case loaded(wallets: [Wallet], selectedIdx: Int)
    case error(error: WalletsViewModel.Error)
}

// MARK - Wallet

extension WalletsViewModel {

    struct Wallet {
        let title: String
    }
}

// MARK: - Error

extension WalletsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}
